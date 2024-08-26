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

func get_setting(key : String) -> Variant:
	return settings[key]

func set_setting(key : String, value : Variant) -> void:
	settings_config.set_value(_setting_key_to_section[key], key, value)

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
				# set resolution
				pass
			"borderless":
				# set borderless
				pass
			"main":
				# set main audio
				pass
			"game":
				# set game audio
				pass
			"ambient":
				# set ambient audio
				pass
			"scheme":
				# set input scheme
				pass
			_:
				push_warning("Unknown setting key <%s> with value <%s>" % [key, setting_value])

func save_settings_to_disk() -> void:
	var err = settings_config.save("user://settings.cfg")
	if err != OK:
		printerr("Error saving settings.cfg: %s" % err)
		return