extends Node
## Provides usable motion input values for gameplay, with built-in gyro aim.
##
## A script intended to be autoloaded as a singleton, which takes in motion 
## data from controllers or mobile devices and provides all functionality needed 
## for gyro aim. For typical gyro aim functionality, a player's camera should 
## take in the [member processed_gyro] variable [b]without[/b] any additional 
## use of [code]delta[/code]. Any relevant settings should be set using the 
## GameSettings singleton provided through [code]scenes/game_settings.gd[/code].
## [br][br]
## Most code here is adapted from guides written by Jibb Smart for his GyroWiki.
# Please keep documentation comments to within 80 character lines when possible.


## The raw, uncalibrated gyroscope values direct from the device. In general, 
## this should not be used for gameplay.
var uncalibrated_gyro := Vector3.ZERO
## The gyroscope values provided after the calibration is applied. This can be 
## used when a direct rotation of the device is needed, but for gyro aim, 
## [member processed_gyro] should be used instead.
var calibrated_gyro := Vector3.ZERO
## This is the processed [Vector2] that should be used directly in camera 
## scripts and such for gyro aim. All player settings such as sensitivity are 
## applied to this variable automatically, so no extra code should be required 
## when applying this to camera rotation. This variable is multiplied by 
## [code]delta[/code] already, so camera scripts should not do this again.
var processed_gyro := Vector2.ZERO
#var processed_uncalibrated_gyro := Vector2.ZERO
## The raw accelerometer input direct from the device. Can be used for gameplay
## if shaking is needed, but for getting the device's rotation in relation to 
## gravity, [member gravity_vector] should be used instead.
var accelerometer := Vector3.ZERO
## The direction of gravity relative to the device, using sensor fusion for 
## better accuracy.
var gravity_vector := Vector3.ZERO

# Calibration variables
var num_offset_samples: int = 0
var accumulated_offset := Vector3.ZERO
var _num_offset_samples_temporary: int = 0
var _accumulated_offset_temporary := Vector3.ZERO

## Is [code]true[/code] if gyro calibration is currently running. If manual 
## gyro calibration is desired, [member calibration_wanted] should be set 
## instead of this variable.
var calibrating := false
## Used to signal if the user is requesting gyro calibration. UI scripts for 
## manual calibration should set this manually, and it is also set automatically 
## if the user has enabled autocalibration.
var calibration_wanted := false
## Sets whether gyro autocalibration is currently being interrupted. Should be 
## set by any UI scene that doesn't want autocalibration, such as a manual 
## calibration screen.
var interrupt_calibration := false
## The hardcoded length for the gyro calibration timer. If [member calibration_timer] 
## goes above this value, the new gyro calibration will be applied. 
var calibration_timer_length: float = 5.0
## The timer used for gyro calibration. Gyro samples will be accumulated while 
## this timer is running, and a new calibration is applied if it goes above 
## [member calibration_timer_length].
var calibration_timer: float = 0.0

## Sets whether noise threshold calibration is wanted. Should [b]not[/b] be set 
## manually, UI scripts should call [method calibrate_noise_thresholds] if they 
## desire calibrating the noise thresholds.
var noise_threshold_calibration_wanted := false
## The current gyroscope noise threshold. If [member gyro_noise] is above this 
## threshold, any currently running gyro calibration process will be reset. 
## Can be set automatically by calling [method calibrate_noise_thresholds], or 
## manually through the game settings.
var gyro_noise_threshold: float = 0.0
## The current accelerometer noise threshold. If [member accel_noise] is above 
## this threshold, any currently running gyro calibration process will be reset. 
## Can be set automatically by calling [method calibrate_noise_thresholds], or 
## manually through the game settings.
var accel_noise_threshold: float = 0.0
## The hardcoded length for the noise threshold calibration timer. 
## If [member noise_threshold_timer] goes above this, the new noise thresholds 
## will be applied.
var noise_threshold_timer_length: float = 5.0
## The timer used for noise threshold calibration. The noise thresholds will be 
## increased to the current peak [member gyro_noise] and [member accel_noise] 
## while this is running, and the noise thresholds will be applied to the game 
## settings when it goes above [member noise_threshold_timer_length].
var noise_threshold_timer: float = 0.0


## The current noise or "stillness" of the gyroscope. When the device is at rest 
## on a still, solid surface, this should represent the sensor noise from the 
## gyroscope. Is used in gyro autocalibration, where the process is reset if 
## this value goes above [member gyro_noise_threshold].
var gyro_noise: float = 0.0
## The current noise or "stillness" of the accelerometer. When the device is at 
## rest on a still, solid surface, this should represent the sensor noise from 
## the acclerometer. Is used in gyro autocalibration, where the process is reset 
## if this value goes above [member accel_noise_threshold].
var accel_noise: float = 0.0

var _gyro_sample_array: PackedFloat64Array
var _accel_sample_array: PackedFloat64Array
var _motion_sample_array_index: int

var _gyro_velocity := Vector3.ZERO
var _gyro_calibration := Vector3.ZERO

# This timer goes up at all times, and is used for the "fake gyro sine wave" on 
# PC when debug mode is enabled.
var _debug_gyro_timer: float = 0.0

# Smoothing variables
var _current_smoothing_buffer_index: int
var _smoothing_input_buffer: PackedVector2Array

## Is [code]true[/code] if the game is running on a mobile device. Can be reused 
## elsewhere if desired.
@onready var is_mobile := OS.has_feature("mobile")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Read the motion from Godot if we're running on mobile
	if is_mobile:
		uncalibrated_gyro.x = rad_to_deg(Input.get_gyroscope().x)
		uncalibrated_gyro.y = rad_to_deg(Input.get_gyroscope().y)
		uncalibrated_gyro.z = rad_to_deg(Input.get_gyroscope().z)
		accelerometer = Input.get_accelerometer()
	
	# If we're in debug mode and not on mobile, oscillate the gyro
	if GameSettings.general["Debug"]["debug_mode"] and not is_mobile:
		_debug_gyro_timer += 1.0 * delta
		uncalibrated_gyro.y = sin(_debug_gyro_timer * 32) * 50 # sine wave
	
	# Process motion arrays
	_process_motion_sample_arrays(16)
	
	# If a noise threshold calibration is requested, run it until it's done
	if noise_threshold_calibration_wanted:
		_process_noise_thresholds(delta)
	else:
		gyro_noise_threshold = GameSettings.general["InputGyro"]["gyro_noise_threshold"]
		accel_noise_threshold = GameSettings.general["InputGyro"]["accel_noise_threshold"]
	
	# Signal that calibration is wanted if autocalibration is on and is not 
	# being interrupted.
	if (GameSettings.general["InputGyro"]["gyro_autocalibration_enabled"] 
			and not interrupt_calibration):
		calibration_wanted = true
	
	if calibration_wanted:
		_process_calibration(delta)
	
	# Apply the gyro calibration
	_gyro_velocity = Vector3(uncalibrated_gyro.x, uncalibrated_gyro.y, uncalibrated_gyro.z)
	_gyro_calibration = Vector3(get_calibration_offset().x, get_calibration_offset().y, get_calibration_offset().z)
	calibrated_gyro = _gyro_velocity - _gyro_calibration
	
	# Update gravity vector
	if calibrated_gyro != Vector3.ZERO:
		_process_simple_gravity(calibrated_gyro, accelerometer.normalized(), delta)
	
	processed_gyro = _get_gyro_aim_input(calibrated_gyro, delta)
	#processed_uncalibrated_gyro = _get_gyro_aim_input(uncalibrated_gyro, delta)


## Returns the current gyro calibration offset, and is used for applying the 
## drift correction to [member calibrated_gyro].
func get_calibration_offset():
	if num_offset_samples == 0:
		return Vector3.ZERO
	return accumulated_offset / num_offset_samples


## Resets the current gyro calibration when called. When starting a manual 
## calibration process in the UI, this should be called first.
func reset_calibration():
	num_offset_samples = 0
	accumulated_offset = Vector3.ZERO


func _reset_temporary_calibration():
	_num_offset_samples_temporary = 0
	_accumulated_offset_temporary = Vector3.ZERO


func _process_calibration(delta: float):
	if calibration_timer < 5:
		calibration_timer += delta
		calibrating = true
		# If we're above the noise threshold, start over
		if (gyro_noise > gyro_noise_threshold * 1.25
				or accel_noise > accel_noise_threshold * 1.25):
			calibration_timer = 0
			_reset_temporary_calibration()
	# Once we're successful, apply the calibration
	else:
		calibrating = false
		calibration_timer = 0
		num_offset_samples = _num_offset_samples_temporary
		accumulated_offset = _accumulated_offset_temporary
		_reset_temporary_calibration()
		
	if calibrating:
		_num_offset_samples_temporary += 1
		_accumulated_offset_temporary += uncalibrated_gyro


## Resets the existing noise threshold values, and signals that calibrating the 
## noise thresholds is desired. Should be called from a UI script as the first 
## stage when the user is running manual gyro calibration.
func calibrate_noise_thresholds():
	_reset_noise_thresholds()
	noise_threshold_timer = 0.0
	noise_threshold_calibration_wanted = true


func _reset_noise_thresholds():
	gyro_noise_threshold = 0.0
	accel_noise_threshold = 0.0


func _process_noise_thresholds(delta: float):
	if noise_threshold_timer < noise_threshold_timer_length:
		noise_threshold_timer += delta
		# Set initial threshold to gyro noise
		if gyro_noise_threshold == 0.0:
			gyro_noise_threshold = gyro_noise
		# Then, only update the threshold to the noise value if it's smaller
		elif gyro_noise_threshold < gyro_noise:
			# If the gyro noise if over a certain times the current threshold, 
			# it's probably a sudden movement spike, so start over
			#if gyro_noise_threshold * 10000 > gyro_noise:
			#	_reset_noise_thresholds()
			#	noise_threshold_timer = 0.0
			#else:
				gyro_noise_threshold = gyro_noise
		# Now the same for accelerometer
		if accel_noise_threshold == 0.0:
			accel_noise_threshold = accel_noise
		elif accel_noise_threshold < accel_noise:
			#if accel_noise_threshold * 1000000000 > accel_noise:
			#	_reset_noise_thresholds()
			#	noise_threshold_timer = 0.0
			#else:
				accel_noise_threshold = accel_noise
	else:
		GameSettings.general["InputGyro"]["gyro_noise_threshold"] = gyro_noise_threshold
		GameSettings.general["InputGyro"]["accel_noise_threshold"] = accel_noise_threshold
		noise_threshold_calibration_wanted = false
		noise_threshold_timer = 0.0


func _process_motion_sample_arrays(buffer_length: int):
	# Get the sample array for gyroscope input
	_motion_sample_array_index = (_motion_sample_array_index + 1) % buffer_length
	_gyro_sample_array.resize(buffer_length)
	_gyro_sample_array[_motion_sample_array_index] = uncalibrated_gyro.length()
	gyro_noise = standard_deviation(_gyro_sample_array)
	# The the same for accelerometer
	_accel_sample_array.resize(buffer_length)
	_accel_sample_array[_motion_sample_array_index] = accelerometer.z
	accel_noise = standard_deviation(_accel_sample_array)


func _get_gyro_aim_input(gyro: Vector3, delta: float):
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
			gyro_delta = _get_player_space_gyro(gyro, gravity_vector)
		2:	# World space
			gyro_delta = _get_world_space_gyro(gyro, gravity_vector)
	
	# Set gyro axis inversion based on settings
	if GameSettings.general["InputGyro"]["gyro_invert_x"]:
		gyro_delta.x = -gyro_delta.x
	if GameSettings.general["InputGyro"]["gyro_invert_y"]:
		gyro_delta.y = -gyro_delta.y
	
	# Apply gyro smoothing if enabled
	if GameSettings.general["InputGyro"]["gyro_smoothing_enabled"]:
		gyro_delta = _get_tiered_smoothed_input(
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
		gyro_delta = _get_tightened_input(gyro_delta,
				GameSettings.general["InputGyro"]["gyro_tightening_threshold"])
	
	# Set sensitivity based on acceleration setting
	if GameSettings.general["InputGyro"]["gyro_accel_enabled"]:
		sens = _get_gyro_acceleration(gyro_delta)
	else:
		sens.x = GameSettings.general["InputGyro"]["gyro_sensitivity_x"]
		sens.y = GameSettings.general["InputGyro"]["gyro_sensitivity_y"]
	
	# Process gyro Vector2 using calculated axes and sensitivity
	var processed := Vector2(gyro_delta.x * sens.x * delta, gyro_delta.y * sens.y * delta)
	return processed


func _process_simple_gravity(gyro: Vector3, accel: Vector3, delta: float):
	# Convert gyro input to reverse rotation
	var gyro_vector := Vector3(deg_to_rad(gyro.x), deg_to_rad(gyro.y), deg_to_rad(gyro.z))
	var rotation := Quaternion(-gyro_vector.normalized(), gyro_vector.length() * delta)
	print(str(-gyro_vector.normalized(), " + ", gyro_vector.length() * delta))
	print(delta)
	
	# Rotate gravity vector
	gravity_vector *= rotation
	
	# Nudge towards gravity according to current acceleration
	var new_gravity: Vector3 = -accel
	gravity_vector += (new_gravity - gravity_vector) * 0.02


func _get_world_space_gyro(gyro: Vector3, gravity: Vector3):
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


func _get_player_space_gyro(gyro: Vector3, gravity: Vector3):
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


# Calculates the sensitivity used for gyro aim when acceleration is on. 
# Takes a Vector2 containing a gyroscope X and Y, which should be the one 
# obtained after the 3DOF to 2DOF conversion in _get_gyro_aim_input().
func _get_gyro_acceleration(gyro: Vector2):
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


func _get_direct_input(input: Vector2):
	return input


func _get_smoothed_input(input: Vector2, buffer_length: int):
	_current_smoothing_buffer_index = (_current_smoothing_buffer_index + 1) % buffer_length
	_smoothing_input_buffer.resize(buffer_length)
	_smoothing_input_buffer[_current_smoothing_buffer_index] = input
	
	var average := Vector2.ZERO
	for sample in _smoothing_input_buffer:
		average += sample
	average /= _smoothing_input_buffer.size()
	
	return average


func _get_tiered_smoothed_input(input: Vector2, min_threshold: float, 
		max_threshold: float, buffer_length: int):
	var input_magnitude: float = sqrt(input.x * input.x + input.y * input.y)
	
	var direct_weight: float = ((input_magnitude - min_threshold) /
			(max_threshold - min_threshold))
	direct_weight = clamp(direct_weight, 0.0, 1.0)
	
	return (_get_direct_input(input * direct_weight)
			+ _get_smoothed_input(input * (1.0 - direct_weight), buffer_length))


func _get_tightened_input(input: Vector2, threshold: float):
	var input_magnitude: float = sqrt(input.x * input.x + input.y * input.y)
	if input_magnitude < threshold:
		var input_scale: float = input_magnitude / threshold
		return input * input_scale
	return input


## Returns the population standard deviation of an [Array] of any length. 
## Is used in this script for calculating noise thresholds.
func standard_deviation(data: Array):
	var sum: float
	var mean: float
	var sd: float
	
	var index: int = 0
	for i in data:
		sum += data[index]
		index += 1
	mean = sum / index
	
	index = 0
	for i in data:
		sd += pow(data[index] - mean, 2)
		index += 1
	
	return sqrt(sd / index)
