extends Node
## Provides all user configurable game settings.
##
## A script intended to be autoloaded as a singleton that provides all 
## game settings as variables. These variables are accessed by calling 
## [b]GameSettings.variable[/b]. When the game is started, all settings files are read 
## and loaded to these variables, with the defaults being written to the files 
## if they don't exist.
##
## @experimental


## Shorthand for the user directory's [DirAccess], used when accessing that 
## folder.
var user_dir = DirAccess.open("user://")

# Set up two config files, one for general settings, one for graphics settings
# This allows for potential cloud sync of settings while keeping graphics local
## Handles the [b]general.cfg[/b] config file. All reads and writes to 
## general.cfg are made through this variable.
var general_settings = ConfigFile.new()
## Loads the [b]general.cfg[/b] file. Returns [b]OK[/b] if successful.
var general_settings_load = general_settings.load("user://cfg/general.cfg")
## Handles the [b]graphics.cfg[/b] config file. All reads and writes to 
## graphics.cfg are made through this variable.
var graphics_settings = ConfigFile.new()
## Loads the [b]graphics.cfg[/b] file. Returns [b]OK[/b] if successful.
var graphics_settings_load = graphics_settings.load("user://cfg/graphics.cfg")

# Start defining settings here
# Meta
## The version of the configuration files, to be written to every .cfg file.
var config_version: int = 5

# Settings in general.cfg
# Debug
## Activates in-game developer features when true, such as debug HUD elements.
var debug_mode := true
# InputMouse
## Horizontal mouselook sensitivity for the player's camera, as a float.
var mouse_sensitivity_x: float = 10.0
## Vertical mouselook sensitivity for the player's camera, as a float.
var mouse_sensitivity_y: float = 10.0
# InputGyro
## Toggles if gyro aim is enabled.
var gyro_enabled := true
## Toggles if gyro autocalibration is enabled. If not, the gyroscope must be 
## calibrated manually.
var gyro_autocalibration_enabled := false
## Horizontal look sensitivity for gyro aim, as a float. Camera rotation on the 
## X axis is multiplied by this amount.
var gyro_sensitivity_x: float = 2.0
## Vertical look sensitivity for gyro aim, as a float. Camera rotation on the 
## Y axis is multiplied by this amount.
var gyro_sensitivity_y: float = 2.0
## Toggles whether horizontal camera rotation is inverted when using gyro aim.
var gyro_invert_x := false
## Toggles whether vertical camera rotation is inverted when using gyro aim.
var gyro_invert_y := false
# TODO: Document remaining gyro variables as these features are added.
var gyro_accel_enabled := false
var gyro_accel_multiplier: float = 2.0
var gyro_accel_min_threshold: float = 0.0
var gyro_accel_max_threshold: float = 75.0
var gyro_smoothing_enabled := false
var gyro_smoothing_threshold: float = 5.0
var gyro_smoothing_buffer: float = 125.0
var gyro_tightening_enabled := false
var gyro_tightening_threshold: float = 5.0
## Sets the conversion method used for converting 3DOF gyroscope input to 2DOF
## camera or pointer movement, also known as "gyro spaces" among gyro aim 
## enthusiasts. 0 is local space, 1 is player space, and 2 is world space. 
## [br][br][b]TODO:[/b] Write descriptions for the gyro space options.
var gyro_space: int = 0 # 0 is local, 1 is player, 2 is world
## Sets which gyroscope axis is used for camera yaw when gyro aim is enabled. 
## 0 is yaw, 1 is roll.
var gyro_local_yaw_axis: int = 0 # 0 is yaw, 1 is roll

# Settings in graphics.cfg
# Display
## The target horizontal window resolution the game, in pixels. This should be 
## set through the [method change_resolution] method rather than directly. 
var resolution_w: int = 1280
## The target vertical window resolution the game, in pixels. This should be 
## set through the [method change_resolution] method rather than directly. 
var resolution_h: int = 720
## The target window mode for the game. Uses the values from [enum Window.Mode]. 
var window_mode: int = 0
## The target vertical sync mode for the game window. Uses the values from 
## [enum DisplayServer.VSyncMode].
var vsync_mode: int = 1
# View
## Sets the camera's vertical field of view in degrees.
var camera_fov: float = 59.0

var general_settings_dict := {
		"Meta": {
				"config_version": config_version,
		},
		"Debug": {
				"debug_mode": debug_mode,
		},
		"InputMouse": {
				"mouse_sensitivity_x": mouse_sensitivity_x,
				"mouse_sensitivity_y": mouse_sensitivity_y,
		},
		"InputGyro": {
				"gyro_enabled": gyro_enabled,
				"gyro_autocalibration_enabled": gyro_autocalibration_enabled,
				"gyro_sensitivity_x": gyro_sensitivity_x,
				"gyro_sensitivity_y": gyro_sensitivity_y,
				"gyro_invert_x": gyro_invert_x,
				"gyro_invert_y": gyro_invert_y,
				"gyro_accel_enabled": gyro_accel_enabled,
				"gyro_accel_multiplier": gyro_accel_multiplier,
				"gyro_accel_min_threshold": gyro_accel_min_threshold,
				"gyro_accel_max_threshold": gyro_accel_max_threshold,
				"gyro_smoothing_enabled": gyro_smoothing_enabled,
				"gyro_smoothing_threshold": gyro_smoothing_threshold,
				"gyro_smoothing_buffer": gyro_smoothing_buffer,
				"gyro_tightening_enabled": gyro_tightening_enabled,
				"gyro_tightening_threshold": gyro_tightening_threshold,
				"gyro_space": gyro_space,
				"gyro_local_yaw_axis": gyro_local_yaw_axis,
		},
}

# Config file sections arry
var general_settings_sections := {
		"Meta": "general_section_meta",
		"Debug": "general_section_debug",
		"InputMouse": "general_section_input_mouse",
		"InputGyro": "general_section_input_gyro",
}

# Arrays of variables in each section
var general_section_meta := {
		"config_version": config_version,
}
var general_section_debug := {
		"debug_mode": debug_mode,
}
var general_section_input_mouse := {
		"mouse_sensitivity_x": mouse_sensitivity_x,
		"mouse_sensitivity_y": mouse_sensitivity_y,
}
var general_section_input_gyro := {
		"gyro_enabled": gyro_enabled,
		"gyro_autocalibration_enabled": gyro_autocalibration_enabled,
		"gyro_sensitivity_x": gyro_sensitivity_x,
		"gyro_sensitivity_y": gyro_sensitivity_y,
		"gyro_invert_x": gyro_invert_x,
		"gyro_invert_y": gyro_invert_y,
		"gyro_accel_enabled": gyro_accel_enabled,
		"gyro_accel_multiplier": gyro_accel_multiplier,
		"gyro_accel_min_threshold": gyro_accel_min_threshold,
		"gyro_accel_max_threshold": gyro_accel_max_threshold,
		"gyro_smoothing_enabled": gyro_smoothing_enabled,
		"gyro_smoothing_threshold": gyro_smoothing_threshold,
		"gyro_smoothing_buffer": gyro_smoothing_buffer,
		"gyro_tightening_enabled": gyro_tightening_enabled,
		"gyro_tightening_threshold": gyro_tightening_threshold,
		"gyro_space": gyro_space,
		"gyro_local_yaw_axis": gyro_local_yaw_axis,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	#debug_dict_sections(general_settings_sections)
	debug_nested_dict(general_settings_dict)
	print("User data directory is ", OS.get_user_data_dir())
	
	# Make config directory if it doesn't exist
	if not user_dir.dir_exists("cfg"):
		print("Config directory missing, creating...")
		user_dir.make_dir("cfg")
	
	if general_settings_load == OK:
		init_config_files(general_settings, general_settings_dict)
		if general_settings.get_value("Meta", "config_version") == 4:
			legacy_load_routine()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func init_config_files(file, file_sections):
	pass # I'm not even ready yet arghhh


func debug_dict_sections(file_sections): # This has been a pain!!
	print(file_sections)
	for section in file_sections:
		var section_key = file_sections.get(section)
		print(section)
		print(section_key)
		#for key in section_key:
			#var value = section_key.get(key)
			#print(key)
			#print(value)


func debug_dict(dict): # So has this!!
	for key in dict:
		print(key)
		print(dict.get(key))


func debug_nested_dict(dict): # Time to try again!!
	for section in dict:
		print(section)
		for key in dict[section]:
			print(key)
			print(dict[section].get(key))


## Immediately sets the window resolution to a width and height in pixels. Does 
## not save to the config file on its own.
func change_resolution(width: int, height: int):
	resolution_w = width
	resolution_h = height
	Window.size = Vector2(resolution_w, resolution_h)


## Sets a setting and saves it. Obsolete, should only be used for config 
## versions <5
##
## @deprecated
func save_input_setting(section: String, key: String, value):
	general_settings.set_value(section, key, value)
	general_settings.save("user://cfg/general_settings.cfg")
	print("Input settings config saved!")


## Obsolete config loading method. Should not be used.
##
## @deprecated
func legacy_load_routine():
	# Load input settings
	if general_settings_load != OK:
		# Initialize input settings
		print("Input settings config doesn't exist, creating...")
		general_settings.set_value("Meta", "config_version", 4)
		general_settings.set_value("Mouselook", "mouse_sensitivity_x", mouse_sensitivity_x)
		general_settings.set_value("Mouselook", "mouse_sensivitity_y", mouse_sensitivity_y)
		general_settings.set_value("Gyro", "gyro_enabled", gyro_enabled)
		general_settings.set_value("Gyro", "gyro_sensitivity_x", gyro_sensitivity_x)
		general_settings.set_value("Gyro", "gyro_sensitivity_y", gyro_sensitivity_y)
		general_settings.save("user://cfg/input.cfg")
		print("Input settings config created!")
	elif general_settings_load == OK:
		mouse_sensitivity_x = general_settings.get_value("Mouselook", "mouse_sensitivity_x")
		mouse_sensitivity_y = general_settings.get_value("Mouselook", "mouse_sensitivity_x")
		gyro_enabled = general_settings.get_value("Gyro", "gyro_enabled")
		gyro_sensitivity_x = general_settings.get_value("Gyro", "gyro_sensitivity_x")
		gyro_sensitivity_y = general_settings.get_value("Gyro", "gyro_sensitivity_x")
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
