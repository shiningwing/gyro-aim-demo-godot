extends Node
## Provides motion vectors to be used for gameplay.
# Shout out to Jibb Smart for the gyro guides, and for pioneering so much of this


var uncalibrated_gyro := Vector3.ZERO
var calibrated_gyro := Vector3.ZERO
var processed_gyro := Vector2.ZERO
var processed_uncalibrated_gyro := Vector2.ZERO

# Calibration variables
var num_offset_samples: int = 0
var accumulated_offset := Vector3.ZERO
var calibrating := false
var calibration_wanted := false
var calibration_timer_running := false
var calibration_timer_length: float = 5.0
var calibration_timer: float = 0.0

var _gyro_velocity := Vector3.ZERO
var _gyro_calibration := Vector3.ZERO

var _debug_gyro_timer: float = 0.0

@onready var is_android := OS.has_feature("android")
@onready var is_ios := OS.has_feature("ios")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Read the gyroscope from Godot if we're running on mobile
	if is_android or is_ios:
		uncalibrated_gyro.x = rad_to_deg(Input.get_gyroscope().x)
		uncalibrated_gyro.y = rad_to_deg(Input.get_gyroscope().y)
		uncalibrated_gyro.z = rad_to_deg(Input.get_gyroscope().z)
	
	# If we're in debug mode and not on mobile, oscillate the gyro
	if GameSettings.general["Debug"]["debug_mode"] and not is_android and not is_ios:
		_debug_gyro_timer += 1 * delta
		uncalibrated_gyro.y = sin(_debug_gyro_timer * 32) * 50 # sine wave
		
		
	
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
			calibration_timer = 0
	
	# Get calibration samples
	if calibrating:
		num_offset_samples += 1
		accumulated_offset += uncalibrated_gyro
	
	# Apply the gyro calibration
	_gyro_velocity = Vector3(uncalibrated_gyro.x, uncalibrated_gyro.y, uncalibrated_gyro.z)
	_gyro_calibration = Vector3(get_calibration_offset().x, get_calibration_offset().y, get_calibration_offset().z)
	if not calibrating:
		calibrated_gyro = _gyro_velocity - _gyro_calibration
	else:
		calibrated_gyro = Vector3.ZERO
	
	processed_gyro = process_gyro_input(calibrated_gyro, delta)
	processed_uncalibrated_gyro = process_gyro_input(uncalibrated_gyro, delta)


func get_calibration_offset():
	if num_offset_samples == 0:
		return Vector3.ZERO
	return accumulated_offset / num_offset_samples


func reset_calibration():
	num_offset_samples = 0
	accumulated_offset = Vector3.ZERO


func process_gyro_input(gyro: Vector3, delta: float):
	# Get base sensitivity from settings config
	var sens: Vector2
	var gyro_delta: Vector2
	
	# Set gyro axes based on yaw/roll setting
	if GameSettings.general["InputGyro"]["gyro_local_use_roll"]:
		gyro_delta.x = gyro.z
		gyro_delta.y = gyro.x
	else:
		gyro_delta.x = gyro.y
		gyro_delta.y = gyro.x
	# Set gyro axis inversion based on settings
	if GameSettings.general["InputGyro"]["gyro_invert_x"]:
		gyro_delta.x = -gyro_delta.x
	if GameSettings.general["InputGyro"]["gyro_invert_y"]:
		gyro_delta.y = -gyro_delta.y
	
	# Apply gyro smoothing if enabled
	if GameSettings.general["InputGyro"]["gyro_smoothing_enabled"]:
		gyro_delta = get_smoothed_input(gyro_delta, roundi(GameSettings.general["InputGyro"]["gyro_smoothing_buffer"]
				* 0.001 * Engine.get_frames_per_second()))
	#	gyro_delta = get_tiered_smoothed_input(
	#			gyro_delta, 
	#			GameSettings.general["InputGyro"]["gyro_smoothing_threshold"] / 2, 
	#			GameSettings.general["InputGyro"]["gyro_smoothing_threshold"], 
	#			# Get buffer length by multiplying the config files's saved 
	#			# length, which is usually a whole number in milliseconds, 
	#			# by 0.001 and then the game's framerate.
	#			roundi(GameSettings.general["InputGyro"]["gyro_smoothing_buffer"]
	#			* 0.001 * Engine.get_frames_per_second())
	#	)
	
	# Apply gyro tightening if enabled
	if GameSettings.general["InputGyro"]["gyro_tightening_enabled"]:
		gyro_delta = get_tightened_input(gyro_delta,
				GameSettings.general["InputGyro"]["gyro_tightening_threshold"])
	
	# Set sensitivity based on acceleration setting
	if GameSettings.general["InputGyro"]["gyro_accel_enabled"]:
		sens = process_gyro_acceleration(gyro_delta)
	else:
		sens.x = GameSettings.general["InputGyro"]["gyro_sensitivity_x"]
		sens.y = GameSettings.general["InputGyro"]["gyro_sensitivity_y"]
	
	# Process gyro Vector2 using calculated axes and sensitivity
	var processed := Vector2(gyro_delta.x * sens.x * delta, gyro_delta.y * sens.y * delta)
	return processed

## Calculates the sensitivity used for gyro aim when acceleration is on. 
## Takes a [Vector2] containing a gyroscope X and Y, which should be the one 
## obtained after the 3DOF to 2DOF conversion in [method process_gyro_input].
func process_gyro_acceleration(gyro: Vector2):
	var sens: Vector2
	sens.x = GameSettings.general["InputGyro"]["gyro_sensitivity_y"]
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
	var input_buffer: PackedVector2Array = []
	var current_input_index: int
	current_input_index = (current_input_index + 1) % buffer_length
	input_buffer.resize(buffer_length)
	input_buffer[current_input_index] = input
	
	var average := Vector2.ZERO
	for sample in input_buffer:
		average += sample
	
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
