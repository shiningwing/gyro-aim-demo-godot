extends HBoxContainer


@export var label: String = "Setting Label"
@export var config_section: String = "SectionName"
@export var config_key: String = "key_name"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.text = label
	if GameSettings.general[config_section][config_key]:
		$CheckButton.button_pressed = true
		$CheckButton.text = "On"
	else:
		$CheckButton.text = "Off"
		$CheckButton.button_pressed = false


func _on_check_button_toggled(toggled_on):
	if toggled_on:
		GameSettings.general[config_section][config_key] = true
		$CheckButton.text = "On"
	else:
		GameSettings.general[config_section][config_key] = false
		$CheckButton.text = "Off"
