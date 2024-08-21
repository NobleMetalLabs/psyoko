class_name Area
extends Resource

var parent_area : Area = null

var _coordinates : Array[Vector2i]

func add_coordinate(coord : Vector2i) -> void:
	_coordinates.append(coord)

func has_coordinate(coord : Vector2i) -> bool:
	return _coordinates.has(coord)

func get_coordinates() -> Array[Vector2i]:
	return _coordinates

var _subareas : Array[Area]

func add_subarea(subarea : Area) -> void:
	_subareas.append(subarea)

func get_subareas() -> Array[Area]:
	return _subareas

var _structures : Array[Structure]

func add_structure(structure : Structure) -> void:
	_structures.append(structure)

func get_structures() -> Array[Structure]:
	return _structures
