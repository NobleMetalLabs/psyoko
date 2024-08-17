class_name ObjectAligner
extends Node

func _ready():
	Aligner.do_event.connect(do_event)
	Aligner.undo_event.connect(undo_event)


func do_event(event : Event) -> void:
	if event is ObjectMoveEvent:
		_do_movement(event as ObjectMoveEvent)

func undo_event(event : Event) -> void:
	if event is ObjectMoveEvent:
		_undo_movement(event as ObjectMoveEvent)


func _do_movement(event : ObjectMoveEvent) -> void:
	if not UIDDB.has_uid(event.object_id): return
	var object = UIDDB.object(event.object_id)
	object.position += Vector2(event.direction) * Psyoko.TILE_SIZE

func _undo_movement(event : ObjectMoveEvent) -> void:
	if not UIDDB.has_uid(event.object_id): return
	var object = UIDDB.object(event.object_id)
	object.position -= Vector2(event.direction) * Psyoko.TILE_SIZE