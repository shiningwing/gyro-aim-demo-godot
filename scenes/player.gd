extends CharacterBody3D


const SPEED: float = 4.0
const JUMP_VELOCITY = 4.5

@export var min_look_angle: float = -90.0
@export var max_look_angle: float = 90.0
@export var mouse_sensitivity_x: float = 10.0
@export var mouse_sensitivity_y: float = 10.0

var mouse_delta: Vector2 = Vector2()

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera: Camera3D = $Camera3D
@onready var camera_x_angle_label: Label = $HUD0/CameraXAngleLabel
@onready var camera_y_angle_label: Label = $HUD0/CameraYAngleLabel


func _ready():
	# Lock mouse cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("player_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector(
			"player_strafeleft",
			"player_straferight",
			"player_forward",
			"player_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func _process(delta):
	# Apply mouselook rotation
	process_mouse_input(delta)
	
	# Exit game when Esc is pressed
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()


func _input(event):
	# Get the mouse delta for mouselook
	if event is InputEventMouseMotion:
		mouse_delta = event.relative


func process_mouse_input(delta):
	# Rotate camera around X axis
	camera.rotation_degrees.x -= mouse_delta.y * mouse_sensitivity_y * delta
	# Clamp camera X rotation
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, min_look_angle, max_look_angle)
	# Rotate player around Y axis
	rotation_degrees.y -= mouse_delta.x * mouse_sensitivity_x * delta
	
	# Zero out mouse delta to avoid input "floating"
	mouse_delta = Vector2.ZERO
	
	# Update camera angles in HUD
	camera_x_angle_label.text = str("Camera X Angle: ", rotation_degrees.y)
	camera_y_angle_label.text = str("Camera Y Angle: ", camera.rotation_degrees.x)
