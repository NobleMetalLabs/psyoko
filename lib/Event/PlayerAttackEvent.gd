class_name PlayerAttackEvent
extends Event

var time : int
var player_id : int
var direction : Vector2i
var is_long : bool

static func setup(_player : Player, _direction : Vector2i, _is_long : bool) -> PlayerAttackEvent:
	var event : PlayerAttackEvent = PlayerAttackEvent.new()
	event.player_id = MultiplayerManager.player_to_peer_id[_player] 
	event.direction = _direction
	event.is_long = _is_long
	event.time = Aligner.get_time()
	return event
