extends Control


@onready var debug_hud: Control = $Debug
@onready var gyro_label: Label = $Debug/TopLeft/GyroLabel
@onready var accel_label: Label = $Debug/TopLeft/AccelLabel
@onready var gyro_calibration_timer_label: Label = $Debug/BottomRight/GyroCalibrationTimerLabel
@onready var gyro_calibrating_label: Label = $Debug/BottomRight/GyroCalibratingLabel
@onready var calibrate_button: Button = $Debug/BottomRight/CalibrateButton

# Called when the node enters the scene tree for the first time.
func _ready():
	if not GameSettings.debug_mode:
		debug_hud.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# Every frame, update the motion labels with raw motion data
	if GameSettings.debug_mode:
		if not debug_hud.visible:
			debug_hud.visible
		update_debug_stats()
	
	if MotionInput.calibrating:
		calibrate_button.visible = false
	else:
		calibrate_button.visible = true


func update_debug_stats():
	gyro_label.text = str("Gyroscope: ", Input.get_gyroscope())
	accel_label.text = str("Accelerometer: ", Input.get_accelerometer())
	gyro_calibration_timer_label.text = str("Calibration Timer: ", MotionInput.calibration_timer)
	gyro_calibrating_label.text = str("Calibrating: ", MotionInput.calibrating)


func _on_calibrate_button_button_up():
	MotionInput.calibration_wanted = true
