extends Control


@onready var calibrate_gyro_button: Button = (
		$MainMenuPanel/VBoxContainer/HeaderContainer/Header/CalibrateGyroButton)


# Called when the node enters the scene tree for the first time.
func _ready():
		pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	if !MotionInput.calibration_timer_running:
		calibrate_gyro_button.text = "Calibrate Gyro"
		calibrate_gyro_button.disabled = false
	if $CalibrationDialogContainer.visible:
		if $CalibrationDialogContainer/CalibrationDialog.visible == false:
			$CalibrationDialogContainer.visible = false


func _on_game_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/level_0.tscn")


func _on_save_settings_button_pressed():
	GameSettings.write_general_config()
	GameSettings.write_graphics_config()


func _on_calibrate_gyro_button_pressed():
	$CalibrationDialogContainer.visible = true
	$CalibrationDialogContainer/CalibrationDialog.visible = true
