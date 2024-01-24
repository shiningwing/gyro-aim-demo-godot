extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
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
