class_name Structure
extends Resource

var bounds : Rect2i
var structure_type : int

func _init(_bounds : Rect2i, type : int) -> void:
	self.bounds = _bounds
	self.structure_type = type
