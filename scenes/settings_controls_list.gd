extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	# Set up variables
	# Mouse + Touch
	$MouseHoriSensitivity/HSlider.value = (
			GameSettings.general["InputMouse"]["mouse_sensitivity_x"])
	$MouseHoriSensitivity/LineEdit.text = str((
			GameSettings.general["InputMouse"]["mouse_sensitivity_x"]))
	$MouseVertSensitivity/HSlider.value = (
			GameSettings.general["InputMouse"]["mouse_sensitivity_y"])
	$MouseVertSensitivity/LineEdit.text = str(
			GameSettings.general["InputMouse"]["mouse_sensitivity_y"])
	
	# Gyro Aim
	$GyroAimEnable/CheckButton.button_pressed = (
			GameSettings.general["InputGyro"]["gyro_enabled"])
	if $GyroAimEnable/CheckButton.button_pressed:
		$GyroAimEnable/CheckButton.text = "On"
	else:
		$GyroAimEnable/CheckButton.text = "Off"
	
	$GyroAutocalibrationEnable/CheckButton.button_pressed = (
			GameSettings.general["InputGyro"]["gyro_autocalibration_enabled"])
	if $GyroAutocalibrationEnable/CheckButton.button_pressed:
		$GyroAutocalibrationEnable/CheckButton.text = "On"
	else:
		$GyroAutocalibrationEnable/CheckButton.text = "Off"
	
	$GyroHoriSensitivity/HSlider.value = (
			GameSettings.general["InputGyro"]["gyro_sensitivity_x"])
	$GyroHoriSensitivity/LineEdit.text = str(
			GameSettings.general["InputGyro"]["gyro_sensitivity_x"])
	$GyroVertSensitivity/HSlider.value = (
			GameSettings.general["InputGyro"]["gyro_sensitivity_y"])
	$GyroVertSensitivity/LineEdit.text = str(
			GameSettings.general["InputGyro"]["gyro_sensitivity_y"])
	
	$GyroInvertHori/CheckButton.button_pressed = (
			GameSettings.general["InputGyro"]["gyro_invert_x"])
	if $GyroInvertHori/CheckButton.button_pressed:
		$GyroInvertHori/CheckButton.text = "On"
	else:
		$GyroInvertHori/CheckButton.text = "Off"
	
	$GyroInvertVert/CheckButton.button_pressed = (
			GameSettings.general["InputGyro"]["gyro_invert_y"])
	if $GyroInvertVert/CheckButton.button_pressed:
		$GyroInvertVert/CheckButton.text = "On"
	else:
		$GyroInvertVert/CheckButton.text = "Off"
	
	# Gyro Acceleration
	$GyroAccel/Enable/CheckButton.button_pressed = (
			GameSettings.general["InputGyro"]["gyro_accel_enabled"])
	if $GyroAccel/Enable/CheckButton.button_pressed:
		$GyroAccel/Enable/CheckButton.text = "On"
	else:
		$GyroAccel/Enable/CheckButton.text = "Off"
	
	$GyroAccel/Multiplier/HSlider.value = (
			GameSettings.general["InputGyro"]["gyro_accel_multiplier"])
	$GyroAccel/Multiplier/LineEdit.text = str(
			GameSettings.general["InputGyro"]["gyro_accel_multiplier"])
	
	$GyroAccel/MinThreshold/HSlider.value = (
			GameSettings.general["InputGyro"]["gyro_accel_min_threshold"])
	$GyroAccel/MinThreshold/LineEdit.text = str(
			GameSettings.general["InputGyro"]["gyro_accel_min_threshold"])
	$GyroAccel/MaxThreshold/HSlider.value = (
			GameSettings.general["InputGyro"]["gyro_accel_max_threshold"])
	$GyroAccel/MaxThreshold/LineEdit.text = str(
			GameSettings.general["InputGyro"]["gyro_accel_max_threshold"])
	
	# TODO: Add GyroSteadying stuff here


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$MouseHoriSensitivity/LineEdit.text = str($MouseHoriSensitivity/HSlider.value)
	$MouseVertSensitivity/LineEdit.text = str($MouseVertSensitivity/HSlider.value)
	$GyroHoriSensitivity/LineEdit.text = str($GyroHoriSensitivity/HSlider.value)
	$GyroVertSensitivity/LineEdit.text = str($GyroVertSensitivity/HSlider.value)


func _on_mouse_hori_sensitivity_slider_drag_ended(value_changed):
	GameSettings.general["InputMouse"]["mouse_sensitivity_x"] = (
			$MouseHoriSensitivity/HSlider.value)


func _on_mouse_vert_sensitivity_slider_drag_ended(value_changed):
	GameSettings.general["InputMouse"]["mouse_sensitivity_y"] = (
			$MouseVertSensitivity/HSlider.value)


func _on_gyro_aim_enabled_toggled(toggled_on):
	if toggled_on:
		GameSettings.general["InputGyro"]["gyro_enabled"] = true
		$GyroAimEnable/CheckButton.text = "On"
	else:
		GameSettings.general["InputGyro"]["gyro_enabled"] = false
		$GyroAimEnable/CheckButton.text = "Off"


func _on_gyro_autocalibration_enabled_toggled(toggled_on):
	if toggled_on:
		GameSettings.general["InputGyro"]["gyro_autocalibration_enabled"] = true
		$GyroAutocalibrationEnable/CheckButton.text = "On"
	else:
		GameSettings.general["InputGyro"]["gyro_autocalibration_enabled"] = false
		$GyroAutocalibrationEnable/CheckButton.text = "Off"


func _on_gyro_hori_sensitivity_slider_drag_ended(value_changed):
	GameSettings.general["InputGyro"]["gyro_sensitivity_x"] = (
			$GyroHoriSensitivity/HSlider.value)


func _on_gyro_vert_sensitivity_slider_drag_ended(value_changed):
	GameSettings.general["InputGyro"]["gyro_sensitivity_y"] = (
			$GyroVertSensitivity/HSlider.value)


func _on_gyro_invert_hori_toggled(toggled_on):
	if toggled_on:
		GameSettings.general["InputGyro"]["gyro_invert_x"] = true
		$GyroInvertHori/CheckButton.text = "On"
	else:
		GameSettings.general["InputGyro"]["gyro_invert_x"] = false
		$GyroInvertHori/CheckButton.text = "Off"


func _on_invert_vert_toggled(toggled_on):
	if toggled_on:
		GameSettings.general["InputGyro"]["gyro_invert_y"] = true
		$GyroInvertVert/CheckButton.text = "On"
	else:
		GameSettings.general["InputGyro"]["gyro_invert_y"] = false
		$GyroInvertVert/CheckButton.text = "Off"
