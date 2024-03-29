extends Control


var view_size
var safe_area
var scale_factor

@onready var is_android = OS.has_feature("android")
@onready var calibration_container = $CalibrationMenuPanel/VBoxContainer/SettingsScrollContainer/CalibrationContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	if is_android:
		if DisplayServer.get_display_cutouts() != []:
			calculate_safe_areas()
	
	$CalibrationMenuPanel/VBoxContainer/HeaderContainer/Header/SaveSettingsButton.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_android:
		if DisplayServer.get_display_cutouts() != []:
			calculate_safe_areas()
	
	if $CalibrationDialogContainer.visible:
		if not $CalibrationDialogContainer/CalibrationDialog.visible:
			$CalibrationDialogContainer.visible = false
			calibration_container.calibrate_button_pressed = false
	
	if calibration_container.calibrate_button_pressed:
		$CalibrationDialogContainer.visible = true
		$CalibrationDialogContainer/CalibrationDialog.visible = true
	
	if Input.is_action_just_pressed("ui_cancel"):
		_on_back_button_pressed()


func _on_save_settings_button_pressed():
	GameSettings.write_general_config()


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu_container.tscn")


func calculate_safe_areas():
	# Get viewport size in actual pixels
	view_size = get_viewport().size
	# Get the scale vactor by dividing the viewport's width by the container's
	# density independent width
	scale_factor = view_size.x / size.x
	# Get the display safe area in actual pixels
	safe_area = DisplayServer.get_display_safe_area()
	
	# Set the margins to the safe area in real pixels divided by the scale factor
	add_theme_constant_override("margin_top", safe_area.position.y / scale_factor)
	add_theme_constant_override("margin_left", safe_area.position.x / scale_factor)
	add_theme_constant_override("margin_bottom", (view_size.y - safe_area.end.y) / scale_factor)
	add_theme_constant_override("margin_right", (view_size.x - safe_area.end.x) / scale_factor)
