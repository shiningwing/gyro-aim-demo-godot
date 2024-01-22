extends Control


var debug_use_uncalibrated_gyro := false

@onready var debug_hud: Control = $Debug
@onready var gyro_label: Label = $Debug/TopLeft/GyroLabel
@onready var calibrated_gyro_label: Label = $Debug/TopLeft/CalibratedGyroLabel
@onready var accel_label: Label = $Debug/TopLeft/AccelLabel
@onready var gravity_label: Label = $Debug/TopLeft/GravityLabel
@onready var gyro_noise_label: Label = $Debug/TopLeft/GyroNoiseLabel
@onready var accel_noise_label: Label = $Debug/TopLeft/AccelNoiseLabel
@onready var gyro_calibration_timer_label: Label = $Debug/Calibration/GyroCalibrationTimerLabel
@onready var gyro_calibrating_label: Label = $Debug/Calibration/GyroCalibratingLabel
@onready var gyro_calibration_samples_label: Label = $Debug/Calibration/GyroCalibrationSamplesLabel
@onready var gyro_calibration_offset_label: Label = $Debug/Calibration/GyroCalibrationOffsetLabel
@onready var calibrate_button: Button = $Debug/Calibration/CalibrateButton
@onready var calibrate_hold_button: Button = $Debug/Calibration/CalibrateHoldButton
@onready var platform_label: Label = $Debug/TopRight/PlatformLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	#if not GameSettings.debug_mode:
	print(GameSettings.general["Debug"]["debug_mode"])
	if not GameSettings.general["Debug"]["debug_mode"]:
		debug_hud.visible = false
	if not OS.has_feature("android") and not OS.has_feature("ios"):
		calibrate_button.visible = false
		calibrate_hold_button.visible = false
	
	platform_label.text = str("Is Android?: ", OS.has_feature("android"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# Every frame, update the motion labels with raw motion data
	if GameSettings.general["Debug"]["debug_mode"]:
		if not debug_hud.visible:
			debug_hud.visible
		update_debug_stats()
	


func update_debug_stats():
	gyro_label.text = str("Gyroscope: ", MotionInput.uncalibrated_gyro)
	accel_label.text = str("Accelerometer: ", Input.get_accelerometer())
	gravity_label.text = str("Sensor Fusion Gravity: ", MotionInput.gravity_vector)
	gyro_noise_label.text = str("Gyroscope Noise: ", MotionInput.gyro_noise)
	accel_noise_label.text = str("Accelerometer Noise: ", MotionInput.accel_noise)
	calibrated_gyro_label.text = str("Calibrated Gyroscope: ", MotionInput.calibrated_gyro)
	gyro_calibration_timer_label.text = str("Calibration Timer: ", MotionInput.calibration_timer)
	gyro_calibrating_label.text = str("Calibrating: ", MotionInput.calibrating)
	gyro_calibration_samples_label.text = str("Calibration Samples: ", MotionInput.num_offset_samples)
	gyro_calibration_offset_label.text = str("Calibration Offset: ", MotionInput.accumulated_offset)


func _on_calibrate_button_button_up():
	MotionInput.calibration_wanted = true


func _on_calibrate_hold_button_pressed():
	MotionInput.calibrating = true


func _on_calibrate_hold_button_released():
	MotionInput.calibrating = false


func _on_quit_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu_container.tscn")
