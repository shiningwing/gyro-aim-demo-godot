extends Node

var user_dir = DirAccess.open("user://")

var input_settings = ConfigFile.new()
var input_settings_load = input_settings.load("user://cfg/input.cfg")
var general_settings = ConfigFile.new()
var general_settings_load = general_settings.load("user://cfg/general.cfg")

# Start defining settings here
# Config version, use this in all of them
var config_version: int = 3

# Input Settings
# Mouselook
var mouse_sensitivity_x: float = 10.0
var mouse_sensitivity_y: float = 10.0
# Gyro
var gyro_enabled := true
var gyro_sensitivity_x: float = 2.0
var gyro_sensitivity_y: float = 2.0

# General
var debug_mode := true

# Graphics
var resolution_w: int = 1280
var resoultion_h: int = 720

# Called when the node enters the scene tree for the first time.
func _ready():
	
	print("User data directory is ", OS.get_user_data_dir())
	
	# Make config directory if it doesn't exist
	if not user_dir.dir_exists("cfg"):
		print("Config directory missing, creating...")
		user_dir.make_dir("cfg")
	
	# Load input settings
	if input_settings_load != OK:
		# Initialize input settings
		print("Input settings config doesn't exist, creating...")
		input_settings.set_value("Meta", "config_version", config_version)
		input_settings.set_value("Mouselook", "mouse_sensitivity_x", mouse_sensitivity_x)
		input_settings.set_value("Mouselook", "mouse_sensivitity_y", mouse_sensitivity_y)
		input_settings.set_value("Gyro", "gyro_enabled", gyro_enabled)
		input_settings.set_value("Gyro", "gyro_sensitivity_x", gyro_sensitivity_x)
		input_settings.set_value("Gyro", "gyro_sensitivity_y", gyro_sensitivity_y)
		input_settings.save("user://cfg/input.cfg")
		print("Input settings config created!")
	elif input_settings_load == OK:
		mouse_sensitivity_x = input_settings.get_value("Mouselook", "mouse_sensitivity_x")
		mouse_sensitivity_y = input_settings.get_value("Mouselook", "mouse_sensitivity_x")
		gyro_enabled = input_settings.get_value("Gyro", "gyro_enabled")
		gyro_sensitivity_x = input_settings.get_value("Gyro", "gyro_sensitivity_x")
		gyro_sensitivity_y = input_settings.get_value("Gyro", "gyro_sensitivity_x")
		print("Input settings config loaded!")
	
	# Load general settings
	if general_settings_load != OK:
		print("General settings config doesn't exist, creating...")
		general_settings.set_value("Meta", "config_version", config_version)
		general_settings.set_value("Debug", "debug_mode", debug_mode)
		general_settings.save("user://cfg/general.cfg")
		print("General settings config created!")
	elif general_settings_load == OK:
		debug_mode = general_settings.get_value("Debug", "debug_mode")
		print("General settings config loaded!")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func save_input_setting(section: String, key: String, value):
	input_settings.set_value(section, key, value)
	input_settings.save("user://cfg/input_settings.cfg")
	print("Input settings config saved!")
