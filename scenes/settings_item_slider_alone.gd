extends HBoxContainer
## A settings list item containing an [HSlider] and [LineEdit] for setting a 
## numerical value.


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

var active := false


# Called when the node enters the scene tree for the first time.
func _ready():
	$HSlider.editable = editable
	$HSlider.value = GameSettings.general[config_section][config_key]
	$HSlider.min_value = min_value
	$HSlider.max_value = max_value
	$HSlider.step = step
	$HSlider.rounded = rounded


func _process(_delta):
	if not active:
		$HSlider.value = GameSettings.general[config_section][config_key]


func _on_h_slider_value_changed(value):
	GameSettings.general[config_section][config_key] = $HSlider.value


func _on_h_slider_drag_started():
	active = true


func _on_h_slider_drag_ended(value_changed):
	active = false
