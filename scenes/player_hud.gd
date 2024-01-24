extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	ProjectSettings.set_setting("input_devices/pointing/emulate_mouse_from_touch", false)
	place_touch_icons()
	if OS.has_feature("pc"):
		visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func place_touch_icons():
	$RightFireButton.position = $RightFirePlaceholder.position
	$RightGyroButton.position = $RightGyroPlaceholder.position
	$ExitButton.position = $ExitPlaceholder.position
