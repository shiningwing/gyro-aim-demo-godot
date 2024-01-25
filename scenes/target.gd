extends Area3D


## The amount of distance the target can move horizontally when shot.
@export var horizontal_range: float = 5.0
## The amount of distance the target can move vertically when shot.
@export var vertical_range: float = 1.75

var is_moved := false
var destroyed := false
var played_sound := false

var start_position: Vector3


# Called when the node enters the scene tree for the first time.
func _ready():
	start_position = position


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
	reposition()

func reposition():
	if not is_moved:
		position.x += randf_range(-horizontal_range, horizontal_range)
		position.y += randf_range(-vertical_range, vertical_range)
		is_moved = true
	else:
		position = start_position
		is_moved = false
