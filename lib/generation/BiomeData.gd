class_name BiomeData
extends Resource

var _vec_to_value : Dictionary = {} #[Vector2i : int]

func set_value(coord : Vector2i, value : int) -> void:
	_vec_to_value[coord] = value

func get_value(coord : Vector2i) -> int:
	if _vec_to_value.has(coord):
		return _vec_to_value[coord]
	else:
		return -1