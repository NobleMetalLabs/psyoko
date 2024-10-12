class_name PlayerAttackEvent
extends Event

var player_id : int
var direction : Vector2i
var is_long : bool

func _to_string() -> String:
	return "PlayerAttackEvent(%s, %s, %s, %s)" % [time, player_id, direction, is_long]

static func setup(_player : Player, _direction : Vector2i, _is_long : bool) -> PlayerAttackEvent:
	var event : PlayerAttackEvent = PlayerAttackEvent.new()
	event.player_id = UIDDB.uid(_player) 
	event.direction = _direction
	event.is_long = _is_long
	event.time = Aligner.get_time()
	return event
