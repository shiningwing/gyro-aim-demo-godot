extends Control


@onready var gyro_label: Label = $GyroLabel
@onready var accel_label: Label = $AccelLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Every frame, update the motion labels with raw motion data
	gyro_label.text = str("Gyroscope: ", Input.get_gyroscope())
	accel_label.text = str("Accelerometer: ", Input.get_accelerometer())
