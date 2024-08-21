class_name Structure
extends Resource

var bounds : Rect2i
var structure_type : int
var subarea_owner : Area

func _init(_bounds : Rect2i, type : int, subarea : Area) -> void:
	self.bounds = _bounds
	self.structure_type = type
	self.subarea_owner = subarea
