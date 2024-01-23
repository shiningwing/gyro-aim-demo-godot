extends PanelContainer


@onready var noise_progress: ProgressBar = $VBoxContainer/NoiseThresholdBox/ProgressContainer/ProgressBar
@onready var gyro_noise_bar: ProgressBar = $VBoxContainer/NoiseThresholdBox/GyroNoiseContainer/ProgressBar
@onready var accel_noise_bar: ProgressBar = $VBoxContainer/NoiseThresholdBox/AccelNoiseContainer/ProgressBar
@onready var gyro_x_bar: ProgressBar = $VBoxContainer/CalibrationBox/GyroXContainer/ProgressBar
@onready var gyro_y_bar: ProgressBar = $VBoxContainer/CalibrationBox/GyroYContainer/ProgressBar
@onready var gyro_z_bar: ProgressBar = $VBoxContainer/CalibrationBox/GyroZContainer/ProgressBar
@onready var gyro_x_label: Label = $VBoxContainer/CalibrationBox/GyroXContainer/Label
@onready var gyro_y_label: Label = $VBoxContainer/CalibrationBox/GyroYContainer/Label
@onready var gyro_z_label: Label = $VBoxContainer/CalibrationBox/GyroZContainer/Label
@onready var calibration_progress: ProgressBar = $VBoxContainer/CalibrationBox/ProgressContainer/ProgressBar

var start_timer: float = 0
var start_timer_running: float = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Only handle this dialog if it's visible
	if visible:
		MotionInput.interrupt_calibration = true
		
		if $VBoxContainer/NoiseThresholdBox.visible:
			gyro_noise_bar.value = MotionInput.gyro_noise
			accel_noise_bar.value = MotionInput.accel_noise
			noise_progress.value = MotionInput.noise_threshold_timer
		
		if start_timer_running:
			if start_timer < 1.0:
				start_timer += delta
			else:
				MotionInput.noise_threshold_calibration_wanted = true
				$VBoxContainer/StartBox.visible = false
				$VBoxContainer/NoiseThresholdBox.visible = true
				start_timer_running = false
				start_timer = 0.0
		
		if ($VBoxContainer/NoiseThresholdBox.visible and not 
				MotionInput.noise_threshold_calibration_wanted):
			$VBoxContainer/NoiseThresholdBox.visible = false
			$VBoxContainer/CalibrationBox.visible = true
			MotionInput.calibration_wanted = true
			MotionInput.reset_calibration()
			MotionInput.calibration_timer = 0.0
		
		if $VBoxContainer/CalibrationBox.visible:
			gyro_x_bar.value = MotionInput.uncalibrated_gyro.x
			gyro_y_bar.value = MotionInput.uncalibrated_gyro.y
			gyro_z_bar.value = MotionInput.uncalibrated_gyro.z
			
			gyro_x_label.text = str(snapped(MotionInput.uncalibrated_gyro.x, 0.01), "°/s")
			gyro_y_label.text = str(snapped(MotionInput.uncalibrated_gyro.y, 0.01), "°/s")
			gyro_z_label.text = str(snapped(MotionInput.uncalibrated_gyro.z, 0.01), "°/s")
			
			calibration_progress.value = MotionInput.calibration_timer
		
		if ($VBoxContainer/CalibrationBox.visible 
				and MotionInput.calibrating == false 
				and MotionInput.num_offset_samples > 0):
			MotionInput.calibration_wanted = false
			calibration_progress.value = 5.0
			$VBoxContainer/CalibrationBox/FinishButton.text = "Finish"
			$VBoxContainer/CalibrationBox/FinishButton.disabled = false



func _on_start_button_pressed():
	if $VBoxContainer/StartBox.visible:
		start_timer_running = true
		$VBoxContainer/StartBox/StartButton.text = "Starting..."
		$VBoxContainer/StartBox/StartButton.disabled = true


func _on_finish_button_pressed():
	visible = false
	$VBoxContainer/CalibrationBox/FinishButton.text = "Calibrating..."
	$VBoxContainer/CalibrationBox/FinishButton.disabled = true
	$VBoxContainer/CalibrationBox.visible = false
	$VBoxContainer/NoiseThresholdBox.visible = false
	$VBoxContainer/StartBox.visible = true
	$VBoxContainer/StartBox/StartButton.disabled = false
	$VBoxContainer/StartBox/StartButton.text = "Start Calibration"
	MotionInput.interrupt_calibration = false
