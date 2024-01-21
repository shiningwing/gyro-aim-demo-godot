extends Node
## A script intended to be used as an autoloaded singleton, which takes in motion 
## data from controllers or mobile devices and provides all functionality needed 
## for gyro aim.
# Shout out to Jibb Smart for the gyro guides, and for pioneering so much of this


var uncalibrated_gyro := Vector3.ZERO
var calibrated_gyro := Vector3.ZERO
var processed_gyro := Vector2.ZERO
var processed_uncalibrated_gyro := Vector2.ZERO
var accelerometer := Vector3.ZERO
var gravity_vector := Vector3.ZERO

# Calibration variables
var num_offset_samples: int = 0
var accumulated_offset := Vector3.ZERO
var accumulated_offset_temporary := Vector3.ZERO

var calibrating := false
var calibration_wanted := false
var calibration_timer_running := false
var calibration_timer_length: float = 5.0
var calibration_timer: float = 0.0

var noise_threshold_calibration_wanted := true
var gyro_noise_threshold: float = 0.0
var accel_noise_threshold: float = 0.0
var noise_threshold_timer_running := true
var noise_threshold_timer_length: float = 5.0
var noise_threshold_timer: float = 0.0

var _gyro_velocity := Vector3.ZERO
var _gyro_calibration := Vector3.ZERO

var _debug_gyro_timer: float = 0.0

# Smoothing variables
var _current_smoothing_buffer_index: int
var _smoothing_input_buffer: PackedVector2Array

@onready var is_android := OS.has_feature("android")
@onready var is_ios := OS.has_feature("ios")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Read the motion from Godot if we're running on mobile
	if is_android or is_ios:
		uncalibrated_gyro.x = rad_to_deg(Input.get_gyroscope().x)
		uncalibrated_gyro.y = rad_to_deg(Input.get_gyroscope().y)
		uncalibrated_gyro.z = rad_to_deg(Input.get_gyroscope().z)
		accelerometer = Input.get_accelerometer()
	
	# If we're in debug mode and not on mobile, oscillate the gyro
	if GameSettings.general["Debug"]["debug_mode"] and not is_android and not is_ios:
		_debug_gyro_timer += 1.0 * delta
		uncalibrated_gyro.y = sin(_debug_gyro_timer * 32) * 50 # sine wave
	
	# Run legacy calibration code for now if needed
	legacy_calibration_process(delta)
	
	# If a noise threshold calibration is requested, run it until it's done
	if noise_threshold_calibration_wanted:
		get_noise_thresholds(delta)
	
	# Apply the gyro calibration
	_gyro_velocity = Vector3(uncalibrated_gyro.x, uncalibrated_gyro.y, uncalibrated_gyro.z)
	_gyro_calibration = Vector3(get_calibration_offset().x, get_calibration_offset().y, get_calibration_offset().z)
	if not calibrating:
		calibrated_gyro = _gyro_velocity - _gyro_calibration
	else:
		calibrated_gyro = Vector3.ZERO
	
	# Update gravity vector
	get_simple_gravity(calibrated_gyro.normalized(), accelerometer.normalized(), delta)
	
	processed_gyro = process_gyro_input(calibrated_gyro, delta)
	processed_uncalibrated_gyro = process_gyro_input(uncalibrated_gyro, delta)


func get_calibration_offset():
	if num_offset_samples == 0:
		return Vector3.ZERO
	return accumulated_offset / num_offset_samples

func reset_calibration():
	num_offset_samples = 0
	accumulated_offset = Vector3.ZERO


func legacy_calibration_process(delta: float):
	# When the user requests timed calibration:
	if calibration_wanted and not calibrating:
		# Start the timer and reset the previous calibration
		calibration_timer_running = true
		reset_calibration()
	if calibration_timer_running:
		if calibration_timer < 1.0:
			calibration_timer += delta
		elif calibration_timer >= 1.0 and calibration_timer < calibration_timer_length + 1.0:
			calibrating = true 
			calibration_timer += delta
		elif calibration_timer >= calibration_timer_length + 1.0:
			calibration_wanted = false
			calibrating = false
			calibration_timer_running = false
			calibration_timer = 0.0
	
	# Get calibration samples
	if calibrating:
		num_offset_samples += 1
		accumulated_offset += uncalibrated_gyro


func calibration_process(delta: float):
	pass


func calibrate_noise_thresholds():
	reset_noise_thresholds()
	noise_threshold_timer = 0.0
	noise_threshold_calibration_wanted = true


func reset_noise_thresholds():
	gyro_noise_threshold = 0.0
	accel_noise_threshold = 0.0


func get_noise_thresholds(delta: float):
	if noise_threshold_timer < noise_threshold_timer_length:
		noise_threshold_timer += delta
		# Set initial threshold to uncalibrated gyro length
		if gyro_noise_threshold == 0.0:
			gyro_noise_threshold = uncalibrated_gyro.length()
		# Then, only update the threshold to the length if it's smaller
		elif gyro_noise_threshold < uncalibrated_gyro.length():
			# If the gyro length if over triple the current threshold, 
			# it's probably a sudden spike, so start over
			if gyro_noise_threshold * 3 > uncalibrated_gyro.length():
				reset_noise_thresholds()
				noise_threshold_timer = 0.0
			else:
				gyro_noise_threshold = uncalibrated_gyro.length()
	else:
		noise_threshold_calibration_wanted = false
		noise_threshold_timer = 0.0


func process_gyro_input(gyro: Vector3, delta: float):
	# Get base sensitivity from settings config
	var sens: Vector2
	var gyro_delta: Vector2
	
	# Convert 3DOF gyro input to 2DOF mouse-like aim input based on user setting
	match GameSettings.general["InputGyro"]["gyro_space"]:
		0:	# Local space
			# Set gyro axes based on yaw/roll setting
			if GameSettings.general["InputGyro"]["gyro_local_use_roll"]:
				gyro_delta.x = gyro.z
				gyro_delta.y = gyro.x
			else:
				gyro_delta.x = gyro.y
				gyro_delta.y = gyro.x
		1:	# Player space
			gyro_delta = get_player_space_gyro(gyro, gravity_vector)
		2:	# World space
			gyro_delta = get_world_space_gyro(gyro, gravity_vector)
	
	# Set gyro axis inversion based on settings
	if GameSettings.general["InputGyro"]["gyro_invert_x"]:
		gyro_delta.x = -gyro_delta.x
	if GameSettings.general["InputGyro"]["gyro_invert_y"]:
		gyro_delta.y = -gyro_delta.y
	
	# Apply gyro smoothing if enabled
	if GameSettings.general["InputGyro"]["gyro_smoothing_enabled"]:
		gyro_delta = get_tiered_smoothed_input(
				gyro_delta, 
				GameSettings.general["InputGyro"]["gyro_smoothing_threshold"] / 2, 
				GameSettings.general["InputGyro"]["gyro_smoothing_threshold"], 
				# Get buffer length by multiplying the config files's saved 
				# length, which is usually a whole number in milliseconds, 
				# by 0.001 and then the game's framerate, and rounding it up.
				ceili(GameSettings.general["InputGyro"]["gyro_smoothing_buffer"]
				* 0.001 * Engine.get_frames_per_second())
		)
	
	# Apply gyro tightening if enabled
	if GameSettings.general["InputGyro"]["gyro_tightening_enabled"]:
		gyro_delta = get_tightened_input(gyro_delta,
				GameSettings.general["InputGyro"]["gyro_tightening_threshold"])
	
	# Set sensitivity based on acceleration setting
	if GameSettings.general["InputGyro"]["gyro_accel_enabled"]:
		sens = get_gyro_acceleration(gyro_delta)
	else:
		sens.x = GameSettings.general["InputGyro"]["gyro_sensitivity_x"]
		sens.y = GameSettings.general["InputGyro"]["gyro_sensitivity_y"]
	
	# Process gyro Vector2 using calculated axes and sensitivity
	var processed := Vector2(gyro_delta.x * sens.x * delta, gyro_delta.y * sens.y * delta)
	return processed


func get_world_space_gyro(gyro: Vector3, gravity: Vector3):
	# Our output, remaining comments are Jibb's
	var processed: Vector2
	
	# Some info about the devices's orientation that we'll use to smooth over boundaries
	var flatness: float = abs(gravity.y) # 1 when device is flat
	var upness: float = abs(gravity.z) # 1 when device
	var side_reduction: float = clamp((max(flatness, upness) - 0.125) / 0.125, 0, 1)
	
	# World space yaw velocity (negative because gravity points down)
	processed.x += gyro.dot(gravity)
	
	# Project pitch axis onto gravity plane
	var gravity_dot_pitch_axis: float = gravity.x
	var pitch_vector: Vector3 = Vector3(1, 0, 0) - gravity * gravity_dot_pitch_axis
	
	# Normalize, it'll be zero if pitch and gravity are parallel, which we ignore
	if (!pitch_vector.is_zero_approx()):
		pitch_vector = pitch_vector.normalized()
		# Camera pitch velocity just like yaw velocity at the beginning
		# (But squish to 0 when device is on its side)
		processed.y += side_reduction * gyro.dot(pitch_vector)
	
	return processed


func get_player_space_gyro(gyro: Vector3, gravity: Vector3):
	# Our output
	var processed: Vector2
	
	# Use world yaw for yaw direction, local combined yaw for magnitude
	# Dot product but just yaw and roll
	var world_yaw: float = gyro.y * gravity.y + gyro.z * gravity.z
	var yaw_relax_factor: float = 2
	processed.x += (
			sign(world_yaw) 
			* min(abs(world_yaw) * yaw_relax_factor, 
			Vector2(gyro.y, gyro.z).length())
	)
	
	# Local pitch, just give back the starting pitch
	processed.y = gyro.x
	
	return processed


## Calculates the sensitivity used for gyro aim when acceleration is on. 
## Takes a [Vector2] containing a gyroscope X and Y, which should be the one 
## obtained after the 3DOF to 2DOF conversion in [method process_gyro_input].
func get_gyro_acceleration(gyro: Vector2):
	var sens: Vector2
	sens.x = GameSettings.general["InputGyro"]["gyro_sensitivity_x"]
	sens.y = GameSettings.general["InputGyro"]["gyro_sensitivity_y"]
	
	var min_threshold: float = GameSettings.general["InputGyro"]["gyro_accel_min_threshold"]
	var max_threshold: float = GameSettings.general["InputGyro"]["gyro_accel_max_threshold"]
	var sens_multiplier: float = GameSettings.general["InputGyro"]["gyro_accel_multiplier"]
	
	# How fast are we turning?
	var speed: float = sqrt(gyro.x * gyro.x + gyro.y * gyro.y)
	
	# How much are we between the acceleration thresholds?
	var slow_fast_factor: float = (speed - min_threshold) / (max_threshold - min_threshold)
	# We're at 0.0 if we're at or below the minimum threshold, and
	# we're at 1.0 if we're at or above the maximum threshold.
	slow_fast_factor = clamp(slow_fast_factor, 0.0, 1.0)
	
	# Get the new sensitivity 
	var new_sens: Vector2
	new_sens.x = (
			# Multiply the slow sens by how low we are in the threshold
			sens.x * (1.0 - slow_fast_factor)
			# And then the fast sens by how high we are in it, then add it up
			+ (sens.x * sens_multiplier) * (slow_fast_factor)
	)
	new_sens.y = (
			# Multiply the slow sens by how low we are in the threshold
			sens.y * (1.0 - slow_fast_factor)
			# And then the fast sens by how high we are in it, then add it up
			+ (sens.y * sens_multiplier) * (slow_fast_factor)
	)
	
	return new_sens


func get_direct_input(input: Vector2):
	return input


func get_smoothed_input(input: Vector2, buffer_length: int):
	_current_smoothing_buffer_index = (_current_smoothing_buffer_index + 1) % buffer_length
	_smoothing_input_buffer.resize(buffer_length)
	_smoothing_input_buffer[_current_smoothing_buffer_index] = input
	
	var average := Vector2.ZERO
	for sample in _smoothing_input_buffer:
		average += sample
	average /= _smoothing_input_buffer.size()
	
	return average


func get_tiered_smoothed_input(input: Vector2, min_threshold: float, 
		max_threshold: float, buffer_length: int):
	var input_magnitude: float = sqrt(input.x * input.x + input.y * input.y)
	
	var direct_weight: float = ((input_magnitude - min_threshold) /
			(max_threshold - min_threshold))
	direct_weight = clamp(direct_weight, 0.0, 1.0)
	
	return (get_direct_input(input * direct_weight)
			+ get_smoothed_input(input * (1.0 - direct_weight), buffer_length))


func get_tightened_input(input: Vector2, threshold: float):
	var input_magnitude: float = sqrt(input.x * input.x + input.y * input.y)
	if input_magnitude < threshold:
		var input_scale: float = input_magnitude / threshold
		return input * input_scale
	return input


func get_simple_gravity(gyro: Vector3, accel: Vector3, delta: float):
	# Convert gyro input to reverse rotation
	var rotation := Quaternion(-gyro, gyro.length() * delta)
	
	# Rotate gravity vector
	gravity_vector *= rotation
	
	# Nudge towards gravity according to current acceleration
	var new_gravity: Vector3 = -accel
	gravity_vector += (new_gravity - gravity_vector) * 0.02
