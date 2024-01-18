extends HBoxContainer
## A settings list item containing an [HSlider] and [LineEdit] for setting a 
## numerical value.

## Sets the [Label] text value.
@export var label: String = "Setting Label"
## Sets the section in the config file used for this setting.
@export var config_section: String = "SectionName"
## Sets the key in the config file used for this setting.
@export var config_key: String = "key_name"

var _debounce_timer := Timer.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	_debounce_timer.wait_time = 0.1
	_debounce_timer.one_shot = true
	$Label.text = label
	$HSlider.value = GameSettings.general[config_section][config_key]
	$LineEdit.text = str(GameSettings.general[config_section][config_key])


func _on_h_slider_value_changed(value):
	if _debounce_timer.time_left == 0:
		_debounce_timer.start()
		$LineEdit.text = str($HSlider.value)
		GameSettings.general[config_section][config_key] = $HSlider.value


func _on_line_edit_text_submitted(new_text):
	pass
