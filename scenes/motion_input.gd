extends Node
# Shout out to Jibb Smart for the gyro guides, and for pioneering so much of this


var uncalibrated_gyro := Vector3.ZERO
var calibrated_gyro := Vector3.ZERO

# Calibration variables
var num_offset_samples: int = 0
var accumulated_offset := Vector3.ZERO
var calibrating := false
var calibration_wanted := false
var calibration_timer_running := false
var calibration_timer_length: float = 5.0
var calibration_timer: float = 0.0

@onready var is_android := OS.has_feature("android")
@onready var is_ios := OS.has_feature("ios")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Read the gyroscope from Godot if we're running on mobile
	if is_android or is_ios:
		uncalibrated_gyro = Input.get_gyroscope()
	
	# Run the calibration timer if wanted
	if calibration_wanted and not calibrating:
		calibration_timer_running = true
	if calibration_timer_running:
		if calibration_timer < calibration_timer_length:
			calibrating = true
			calibration_timer += delta
		else:
			calibration_wanted = false
			calibrating = false
			calibration_timer_running = false
	
	if calibrating:
		num_offset_samples += 1
		accumulated_offset += uncalibrated_gyro
	
	var gyro_velocity := Vector2(uncalibrated_gyro.x, uncalibrated_gyro.y)
	var gyro_calibration := Vector2(get_calibration_offset().x, get_calibration_offset().y)
	var calibrated_gyro := gyro_velocity - gyro_calibration


func get_calibration_offset():
	if num_offset_samples == 0:
		return Vector3.ZERO
	return accumulated_offset / num_offset_samples


func reset_calibration():
	num_offset_samples = 0
	accumulated_offset = Vector3.ZERO
