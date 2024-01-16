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
var general_config = ConfigFile.new()
## Loads the [b]general.cfg[/b] file. Returns [b]OK[/b] if successful.
var general_config_load = general_config.load("user://cfg/general.cfg")
## Handles the [b]graphics.cfg[/b] config file. All reads and writes to 
## graphics.cfg are made through this variable.
var graphics_config = ConfigFile.new()
## Loads the [b]graphics.cfg[/b] file. Returns [b]OK[/b] if successful.
var graphics_config_load = graphics_config.load("user://cfg/graphics.cfg")

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

## A dictionary that contains all "general" settings values and sections that 
## are saved in [b]general.cfg[/b]. This includes nearly everything other than 
## graphics settings, and should be suitable for potential cloud syncing across 
## multiple machines, unlike the graphics settings. [br][br]
## This dictionary should be referenced whenever a setting is needed, by using
## [code]GameSettings.general[SectionName][key_name][/code]. [br][br]
## [b]TODO:[/b] Move over the key descriptions from the bespoke variables.
var general := {
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

## A dictionary containing the graphics and diplay settings contained in
## [b]graphics.cfg[/b], as a separate config file that can be safely left out of 
## any cloud sync mechanism. [br][br]
## This dictionary should be referenced whenever a setting is needed, by using
## [code]GameSettings.graphics[SectionName][key_name][/code]. Settings in the 
## [b]Display[/b] section should generally be set with their dedicated methods 
## rather than directly. [br][br]
## [b]TODO:[/b] Move over the key descriptions from the bespoke variables.
var graphics := {
	"Meta": {
		"config_version": config_version,
	},
	"Display": {
		"resolution_w": resolution_w,
		"resolution_h": resolution_h,
		"window_mode": window_mode,
		"vsync_mode": vsync_mode,
	},
	"View": {
		"camera_fov": camera_fov
	},
}


# Called when the node enters the scene tree for the first time.
func _ready():
	print("User data directory is ", OS.get_user_data_dir())
	
	# Make config directory if it doesn't exist
	if not user_dir.dir_exists("cfg"):
		print("Config directory missing, creating...")
		user_dir.make_dir("cfg")
	
	# If general.cfg is OK, load its values, else write the defaults immediately
	if general_config_load == OK:
		load_config(general_config, general)
	else: write_general_config()
	# Same with graphics.cfg
	if graphics_config_load == OK:
		load_config(graphics_config, graphics)
	else: write_graphics_config()
	
	write_general_config()
	write_graphics_config()
	
	# Set the display settings outside of mobile
	if not OS.has_feature("android") and not OS.has_feature("ios"):
		DisplayServer.window_set_size(Vector2i(
				graphics["Display"]["resolution_w"],
				graphics["Display"]["resolution_h"]), 0)
		DisplayServer.window_set_mode(graphics["Display"]["window_mode"])
		DisplayServer.window_set_vsync_mode(graphics["Display"]["vsync_mode"])


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func load_config(file, dict):
	for section in dict:
		for key in dict[section]:
			var value = dict[section].get(key)
			print(section, " - ", key)
			var loaded_value = file.get_value(section, key)
			if file.has_section_key(section, key):
				#key = loaded_value
				dict[section][key] = loaded_value
				print("Loaded: ", loaded_value)
			else:
				file.set_value(section, key, value)


func write_config(file, dict, location):
	for section in dict:
		for key in dict[section]:
			var value = dict[section].get(key)
			file.set_value(section, key, value)
	file.save(location)


func write_general_config():
	write_config(general_config, general, "user://cfg/general.cfg")
	print("Wrote to general config!")


func write_graphics_config():
	write_config(graphics_config, graphics, "user://cfg/graphics.cfg")
	print("Wrote to graphics config!")


## Immediately sets the window resolution to a width and height in pixels. Does 
## not save to the config file on its own.
func set_resolution(width: int, height: int):
	graphics["Display"]["resolution_h"] = width
	graphics["Display"]["resolution_w"] = height
	DisplayServer.window_set_size(Vector2i(width, height), 0)


## Immediately sets the vertical sync mode. Does not save to the config file on 
## its own.
func set_vsync_mode(mode: int):
	graphics["Display"]["vsync_mode"] = mode
	DisplayServer.window_set_vsync_mode(mode)

## Immediately sets the window mode. Does not save to the config file on its own.
func set_window_mode(mode: int):
	graphics["Display"]["window_mode"] = mode
	DisplayServer.window_set_mode(mode)

