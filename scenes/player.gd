extends CharacterBody3D


const SPEED: float = 4.0
const JUMP_VELOCITY = 4.5

@export var min_look_angle: float = -90.0
@export var max_look_angle: float = 90.0

var mouse_delta := Vector2.ZERO
var gyro_delta := Vector2.ZERO

var is_gyro_active := true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera: Camera3D = $Camera3D
@onready var camera_x_angle_label: Label = $HUD0/Debug/TopLeft/CameraXAngleLabel
@onready var camera_y_angle_label: Label = $HUD0/Debug/TopLeft/CameraYAngleLabel


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
	process_mouse_look(delta)
	
	# Set what the gyro modifier button does when pressed
	match GameSettings.general["InputGyro"]["gyro_modifier_mode"]:
		0:	# Gyro modifer turns gyro off when held (typical "ratcheting")
			if Input.is_action_pressed("player_gyro_modifier"):
				is_gyro_active = false
			else: is_gyro_active = true
		1:	# Gyro modifer turns gyro on when held
			if Input.is_action_pressed("player_gyro_modifier"):
				is_gyro_active = true
			else: is_gyro_active = false
		2:	# Gyro modifier toggles gyro on or off when pressed
			if Input.is_action_just_pressed("player_gyro_modifier"):
				is_gyro_active = !is_gyro_active
	
	# Apply gyro aim rotation if gyro should be active
	if (GameSettings.general["InputGyro"]["gyro_enabled"]
		and is_gyro_active):
		process_gyro_look(delta)
	
	clamp_camera()
	
	# Exit game when Esc is pressed
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	
	if GameSettings.general["Debug"]["debug_mode"]:
		if Input.is_action_just_pressed("debug_startgyrocalibration"):
			MotionInput.calibration_wanted = true
		if Input.is_action_pressed("debug_calibrategyro"):
			MotionInput.calibrating = true
	#else:
	#	MotionInput.calibrating = false
	
	camera.fov = GameSettings.graphics["View"]["camera_fov"]


func _input(event):
	# Get the mouse delta for mouselook
	if event is InputEventMouseMotion:
		mouse_delta = event.relative


func process_mouse_look(delta):
	var sens_x: float = GameSettings.general["InputMouse"]["mouse_sensitivity_x"]
	var sens_y: float = GameSettings.general["InputMouse"]["mouse_sensitivity_y"]
	# Rotate camera around X axis
	camera.rotation_degrees.x -= mouse_delta.y * sens_y * delta
	# Rotate player around Y axis
	rotation_degrees.y -= mouse_delta.x * sens_x * delta
	
	# Zero out mouse delta to avoid camera "floating"
	mouse_delta = Vector2.ZERO
	
	


func process_gyro_look(delta):
	# Prepare gyro delta from X and Y of the global calibrated gyro
	gyro_delta = MotionInput.processed_gyro
	
	# DON'T use delta time for gyro because that's handled by MotionInput!
	# Rotate camera around X axis
	camera.rotation_degrees.x += MotionInput.processed_gyro.y
	# Rotate player around Y axis
	rotation_degrees.y += MotionInput.processed_gyro.x
	
	# Zero out gyro delta to avoid camera "floating"
	gyro_delta = Vector2.ZERO


func clamp_camera():
	# Clamp camera X rotation
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, min_look_angle, max_look_angle)
	# Update camera angles in debug HUD
	camera_x_angle_label.text = str("Camera X Angle: ", rotation_degrees.y)
	camera_y_angle_label.text = str("Camera Y Angle: ", camera.rotation_degrees.x)
