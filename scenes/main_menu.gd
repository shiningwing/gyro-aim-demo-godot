extends Control


@onready var toggle_debug_button: Button = (
		$MainMenuPanel/VBoxContainer/HeaderContainer/Header/ToggleDebugButton)


# Called when the node enters the scene tree for the first time.
func _ready():
	if GameSettings.general["Debug"]["debug_mode"]:
		toggle_debug_button.button_pressed = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()


func _on_game_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/level_0.tscn")


func _on_save_settings_button_pressed():
	GameSettings.write_general_config()
	GameSettings.write_graphics_config()


func _on_toggle_debug_button_toggled(toggled_on):
	if toggled_on:
		GameSettings.general["Debug"]["debug_mode"] = true
	else:
		GameSettings.general["Debug"]["debug_mode"] = false
