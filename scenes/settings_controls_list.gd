extends VBoxContainer


# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Only show the gyro aim settings if it's on
	if $GyroAimEnable/CheckButton.button_pressed:
		$GyroSettings.visible = true
		# Handle visibility for other sections when gyro is on
		if $GyroSettings/GyroAccelEnable/CheckButton.button_pressed:
			$GyroSettings/GyroAccelSettings.visible = true
		else:
			$GyroSettings/GyroAccelSettings.visible = false
		if $GyroSettings/GyroSmoothingEnable/CheckButton.button_pressed:
			$GyroSettings/GyroSmoothingSettings.visible = true
		else:
			$GyroSettings/GyroSmoothingSettings.visible = false
		if $GyroSettings/GyroTighteningEnable/CheckButton.button_pressed:
			$GyroSettings/GyroTighteningSettings.visible = true
		else:
			$GyroSettings/GyroTighteningSettings.visible = false
		if GameSettings.general["InputGyro"]["gyro_space"] == 0:
			$GyroSettings/GyroLocalUseRoll.visible = true
		else:
			$GyroSettings/GyroLocalUseRoll.visible = false
	else:
		$GyroSettings.visible = false


func _on_gyro_calibration_settings_button_pressed():
	get_tree().change_scene_to_file("res://scenes/settings_calibration_menu_container.tscn")
