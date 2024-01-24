extends Area3D


var destroyed := false
var played_sound := false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if destroyed:
		visible = false
		monitorable = false
		if not played_sound:
			$BreakSound.play()
			played_sound = true
		if played_sound and not $BreakSound.playing:
			queue_free()


func destroy():
	destroyed = true

func hit():
	$BreakSound.play()
