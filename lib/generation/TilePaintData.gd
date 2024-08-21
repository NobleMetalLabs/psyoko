class_name TilePaintData
extends Resource

var _vec_to_value : Dictionary = {} #[Vector2i : Vector2i]

func set_value(coord : Vector2i, value : Vector2i) -> void:
	_vec_to_value[coord] = value

func get_value(coord : Vector2i) -> Vector2i:
	if _vec_to_value.has(coord):
		return _vec_to_value[coord]
	else:
		return Vector2i.UP + Vector2i.LEFT
