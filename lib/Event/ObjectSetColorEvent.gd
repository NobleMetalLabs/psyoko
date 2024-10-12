class_name ObjectSetColorEvent
extends Event

var object_id : int
var color : Color
var previous_color : Color

func _to_string() -> String:
	return "ObjectSetColorEvent(%s, %s, %s, %s)" % [time, object_id]

static func setup(_object_id : int, _color: Color) -> ObjectSetColorEvent:
	var event : ObjectSetColorEvent = ObjectSetColorEvent.new()
	event.object_id = _object_id
	event.color = _color
	event.time = Aligner.get_time()
	event.previous_color = UIDDB.object(_object_id).modulate
	return event
