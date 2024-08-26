#class_name Psyoko
extends Node

const SCREEN_SCALE : int = 10

const TILE_SIZE : int = 16
const CHUNK_SIZE : int = 16

const MAX_TARGET_DISTANCE : int = 2 * CHUNK_SIZE * TILE_SIZE

func get_coordinate_neighbors(coord : Vector2i, include_diagonals : bool = false) -> Array[Vector2i]:
	var neighbors : Array[Vector2i] = []
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			if dx == 0 and dy == 0: continue
			if (dx != 0 and dy != 0):
				if not include_diagonals: continue
			neighbors.append(coord + Vector2i(dx, dy))
	return neighbors


func _ready():
	_load_settings()

var settings : Dictionary : 
	get:
		var settings_dict : Dictionary = {}
		for section in settings_config.get_sections():
			for key in settings_config.get_section_keys(section):
				settings_dict[key] = settings_config.get_value(section, key)
		return settings_dict

var settings_config : ConfigFile = ConfigFile.new()
func _load_settings() -> void:
	var err = settings_config.load("user://settings.cfg")
	if err == OK:
		pass
	elif err == ERR_FILE_NOT_FOUND:
		settings_config.load("res://ast/default_settings.cfg")
	else:
		printerr("Error loading settings.cfg: %s" % err)
		return
