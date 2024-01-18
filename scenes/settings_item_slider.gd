extends HBoxContainer
## A settings list item containing an [HSlider] and [LineEdit] for setting a 
## numerical value.

## Sets the [Label] text value.
@export var label := "Setting Label"
## Sets the section in the config file used for this setting.
@export var config_section := "SectionName"
## Sets the key in the config file used for this setting.
@export var config_key := "key_name"
## Sets whether the setting is editable.
@export var editable := true
## Sets the slider's minimum value as [member Range.min_value].
@export var min_value: float = 0
## Sets the slider's maximum value as [member Range.max_value].
@export var max_value: float = 100
## Sets the "step" number which the slider is always rounded to, using 
## [member Range.step].
@export var step: float = 0
## Sets whether the slider's value is rounded to the nearest integer, using 
## [member Range.rounded].
@export var rounded := false
## Sets the [LineEdit]'s maximum length.
@export var max_length: int = 5

var _debounce_timer := Timer.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	_debounce_timer.wait_time = 0.1
	_debounce_timer.one_shot = true
	$Label.text = label
	$HSlider.editable = editable
	$HSlider.value = GameSettings.general[config_section][config_key]
	$HSlider.min_value = min_value
	$HSlider.max_value = max_value
	$HSlider.step = step
	$HSlider.rounded = rounded
	$LineEdit.text = str(GameSettings.general[config_section][config_key])
	$LineEdit.editable = editable
	$LineEdit.max_length = max_length


func _on_h_slider_value_changed(value):
	if _debounce_timer.time_left == 0:
		_debounce_timer.start()
		$LineEdit.text = str($HSlider.value)
		GameSettings.general[config_section][config_key] = $HSlider.value


func _on_line_edit_text_submitted(new_text):
	pass
