class_name PsyokoSettings
extends Node

var settings_config : ConfigFile = ConfigFile.new()
var settings : Dictionary : 
	get:
		var settings_dict : Dictionary = {}
		for section in settings_config.get_sections():
			for key in settings_config.get_section_keys(section):
				_setting_key_to_section[key] = section
				settings_dict[key] = settings_config.get_value(section, key)
		return settings_dict
var _setting_key_to_section : Dictionary = {}

func _init(parent : Node) -> void:
	parent.add_child(self)

func _ready() -> void:
	load_settings_from_disk()
	apply_settings_to_game()

func get_setting(key : String) -> Variant:
	if key not in settings:
		var input_result : Key = scheme_keys.get(key)
		if input_result == null:
			push_error("Setting key <%s> not found in settings." % key)
			return null
		return input_result
	return settings[key]

var scheme_keys : Dictionary = { 
		"input_0_pl_up_keycode" : KEY_W ,
		"input_0_pl_down_keycode" : KEY_S,
		"input_0_pl_left_keycode" : KEY_A,
		"input_0_pl_right_keycode" : KEY_D,
		"input_0_pl_attack_keycode" : KEY_SHIFT,
		"input_1_pl_up_keycode" : KEY_UP,
		"input_1_pl_down_keycode" : KEY_DOWN,
		"input_1_pl_left_keycode" : KEY_LEFT,
		"input_1_pl_right_keycode" : KEY_RIGHT,
		"input_1_pl_attack_keycode" : KEY_SHIFT,
	}

func set_setting(key : String, value : Variant, apply_setting : bool = true) -> void:
	settings_config.set_value(_setting_key_to_section[key], key, value)
	if apply_setting: apply_settings_to_game([key])

func load_settings_from_disk() -> void:
	var err = settings_config.load("user://settings.cfg")
	if err == OK:
		pass
	elif err == ERR_FILE_NOT_FOUND:
		settings_config.load("res://ast/default_settings.cfg")
	else:
		printerr("Error loading settings.cfg: %s" % err)
		return

func apply_settings_to_game(setting_keys = settings.keys()) -> void:
	for key in setting_keys:
		var setting_value = settings[key]
		match(key):
			"resolution":
				get_window().content_scale_size = settings["resolution"]
				Psyoko.SCREEN_SCALE = settings["resolution"] / Psyoko.BASE_SCREEN_RES
			"borderless":
				DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, settings["borderless"])
			"main":
				AudioServer.set_bus_volume_db(0, linear_to_db(settings["main"]))
			"game":
				AudioServer.set_bus_volume_db(1, linear_to_db(settings["game"]))
			"ambient":
				AudioServer.set_bus_volume_db(2, linear_to_db(settings["ambient"]))

	var input_actions : Array[StringName] = InputMap.get_actions()
	var player_actions : Array[StringName] = input_actions.filter(func (action : StringName) -> bool: return action.begins_with("pl"))
	var input_scheme = settings["scheme"]
	for action : StringName in player_actions:
		if action == "pl_quit": continue
		var action_keycode : Key = get_setting("input_%s_%s_keycode" % [input_scheme, action])
		var new_event : InputEventKey = InputEventKey.new()
		new_event.keycode = action_keycode
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, new_event)

func save_settings_to_disk() -> void:
	var err = settings_config.save("user://settings.cfg")
	if err != OK:
		printerr("Error saving settings.cfg: %s" % err)
		return
