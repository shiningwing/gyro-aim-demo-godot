extends PanelContainer


@onready var gyro_x_bar: ProgressBar = $ListContainer/CalibrationBox/GyroXContainer/ProgressBar
@onready var gyro_x_label: Label = $ListContainer/CalibrationBox/GyroXContainer/Label
@onready var gyro_y_bar: ProgressBar = $ListContainer/CalibrationBox/GyroYContainer/ProgressBar
@onready var gyro_y_label: Label = $ListContainer/CalibrationBox/GyroYContainer/Label
@onready var gyro_z_bar: ProgressBar = $ListContainer/CalibrationBox/GyroZContainer/ProgressBar
@onready var gyro_z_label: Label = $ListContainer/CalibrationBox/GyroZContainer/Label

@onready var autocalibration_progress: ProgressBar = $ListContainer/CalibrationBox/Autocalibration/ProgressContainer/ProgressBar
@onready var gyro_noise_bar: ProgressBar = $ListContainer/CalibrationBox/NoiseThresholds/GyroNoiseContainer/ProgressBar
@onready var accel_noise_bar: ProgressBar = $ListContainer/CalibrationBox/NoiseThresholds/AccelNoiseContainer/ProgressBar

@onready var autocalibration_container = $ListContainer/CalibrationBox/Autocalibration/ProgressContainer
@onready var noise_thresholds_container = $ListContainer/CalibrationBox/NoiseThresholds

var calibrate_button_pressed := false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	gyro_x_bar.value = MotionInput.calibrated_gyro.x
	gyro_y_bar.value = MotionInput.calibrated_gyro.y
	gyro_z_bar.value = MotionInput.calibrated_gyro.z
	gyro_x_label.text = str(snapped(MotionInput.calibrated_gyro.x, 0.01), "°/s")
	gyro_y_label.text = str(snapped(MotionInput.calibrated_gyro.y, 0.01), "°/s")
	gyro_z_label.text = str(snapped(MotionInput.calibrated_gyro.z, 0.01), "°/s")
	
	if GameSettings.general["InputGyro"]["gyro_autocalibration_enabled"]:
		autocalibration_container.visible = true
		noise_thresholds_container.visible = true
		autocalibration_progress.value = MotionInput.calibration_timer
		gyro_noise_bar.value = MotionInput.gyro_noise
		accel_noise_bar.value = MotionInput.accel_noise
	else:
		autocalibration_container.visible = false
		noise_thresholds_container.visible = false


func _on_calibrate_button_pressed():
	calibrate_button_pressed = true
