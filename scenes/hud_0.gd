extends Control


@onready var debug_hud: Control = $Debug
@onready var gyro_label: Label = $Debug/GyroLabel
@onready var accel_label: Label = $Debug/AccelLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	if not GameSettings.debug_mode:
		debug_hud.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# Every frame, update the motion labels with raw motion data
	if GameSettings.debug_mode:
		if not debug_hud.visible:
			debug_hud.visible
		update_debug_stats()


func update_debug_stats():
	gyro_label.text = str("Gyroscope: ", Input.get_gyroscope())
	accel_label.text = str("Accelerometer: ", Input.get_accelerometer())
