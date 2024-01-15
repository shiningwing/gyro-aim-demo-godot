extends Control


var debug_use_uncalibrated_gyro := false

@onready var debug_hud: Control = $Debug
@onready var gyro_label: Label = $Debug/TopLeft/GyroLabel
@onready var calibrated_gyro_label: Label = $Debug/TopLeft/CalibratedGyroLabel
@onready var accel_label: Label = $Debug/TopLeft/AccelLabel
@onready var gyro_calibration_timer_label: Label = $Debug/BottomRight/GyroCalibrationTimerLabel
@onready var gyro_calibrating_label: Label = $Debug/BottomRight/GyroCalibratingLabel
@onready var calibrate_button: Button = $Debug/BottomRight/CalibrateButton
@onready var platform_label: Label = $Debug/TopRight/PlatformLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	if not GameSettings.debug_mode:
		debug_hud.visible = false
	
	platform_label.text = str("Is Android?: ", OS.has_feature("android"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# Every frame, update the motion labels with raw motion data
	if GameSettings.debug_mode:
		if not debug_hud.visible:
			debug_hud.visible
		update_debug_stats()
	


func update_debug_stats():
	gyro_label.text = str("Gyroscope: ", MotionInput.uncalibrated_gyro)
	accel_label.text = str("Accelerometer: ", Input.get_accelerometer())
	calibrated_gyro_label.text = str("Calibrated Gyroscope: ", MotionInput.calibrated_gyro)
	gyro_calibration_timer_label.text = str("Calibration Timer: ", MotionInput.calibration_timer)
	gyro_calibrating_label.text = str("Calibrating: ", MotionInput.calibrating)


func _on_calibrate_button_button_up():
	MotionInput.calibration_wanted = true


func _on_calibrate_hold_button_pressed():
	MotionInput.calibrating = true


func _on_calibrate_hold_button_released():
	MotionInput.calibrating = false


func _on_uncalibrated_gyro_button_toggled(toggled_on):
	if toggled_on:
		debug_use_uncalibrated_gyro = true
	else:
		debug_use_uncalibrated_gyro = false
