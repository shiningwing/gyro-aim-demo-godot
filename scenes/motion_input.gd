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
	if GameSettings.general["InputGyro"]["gyro_local_yaw_axis"] == 1:
		gyro_delta.x = gyro.z
		gyro_delta.y = gyro.x
	else:
		gyro_delta.x = gyro.y
		gyro_delta.y = gyro.x
	
	# Set sensitivity based on acceleration setting
	if GameSettings.general["InputGyro"]["gyro_accel_enabled"]:
		pass
	else:
		sens.x = GameSettings.general["InputGyro"]["gyro_sensitivity_x"]
		sens.y = GameSettings.general["InputGyro"]["gyro_sensitivity_y"]
	
	# Process gyro Vector2 using calculated axes and sensitivity
	var processed := Vector2(gyro_delta.x * sens.x * delta, gyro_delta.y * sens.y * delta)
	return processed

func process_gyro_acceleration(gyro: Vector2, delta: float):
	var new_sens: Vector2
	# Just give back the old sensitivity until you're ready okay?
	new_sens.x = GameSettings.general["InputGyro"]["gyro_sensitivity_x"]
	new_sens.y = GameSettings.general["InputGyro"]["gyro_sensitivity_y"]
	
	return new_sens
