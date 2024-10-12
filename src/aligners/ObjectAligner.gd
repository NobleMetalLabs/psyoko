class_name ObjectAligner
extends Node

func _ready():
	Aligner.do_event.connect(do_event)
	Aligner.undo_event.connect(undo_event)


func do_event(event : Event) -> void:
	if event is ObjectMoveEvent:
		_do_movement(event as ObjectMoveEvent)
	elif event is ObjectSetColorEvent:
		_do_set_color(event as ObjectSetColorEvent)

func undo_event(event : Event) -> void:
	if event is ObjectMoveEvent:
		_undo_movement(event as ObjectMoveEvent)
	elif event is ObjectSetColorEvent:
		_undo_set_color(event as ObjectSetColorEvent)


func _do_movement(event : ObjectMoveEvent) -> void:
	if not UIDDB.has_uid(event.object_id): return
	var object = UIDDB.object(event.object_id)
	object.position += Vector2(event.direction) * Psyoko.TILE_SIZE

func _undo_movement(event : ObjectMoveEvent) -> void:
	if not UIDDB.has_uid(event.object_id): return
	var object = UIDDB.object(event.object_id)
	object.position -= Vector2(event.direction) * Psyoko.TILE_SIZE

func _do_set_color(event : ObjectSetColorEvent) -> void:
	if not UIDDB.has_uid(event.object_id): return
	var object = UIDDB.object(event.object_id)
	object.modulate = event.color

func _undo_set_color(event : ObjectSetColorEvent) -> void:
	if not UIDDB.has_uid(event.object_id): return
	var object = UIDDB.object(event.object_id)
	object.modulate = event.previous_color
