class_name Area
extends Resource

var _coordinates : Array[Vector2i]

func add_coordinate(coord : Vector2i) -> void:
	_coordinates.append(coord)

func get_coordinates() -> Array[Vector2i]:
	return _coordinates