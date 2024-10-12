class_name ObjectMoveEvent
extends Event

var object_id : int
var direction : Vector2i

func _to_string() -> String:
	return "ObjectMoveEvent(%s, %s, %s)" % [time, object_id, direction]

static func setup(_object : Object, _direction : Vector2i) -> ObjectMoveEvent:
	var event : ObjectMoveEvent = ObjectMoveEvent.new()
	event.object_id = UIDDB.uid(_object)
	event.direction = _direction
	event.time = Aligner.get_time()
	return event
