class_name PlayerMoveEvent
extends Event

var time : int
var player_id : int
var direction : Vector2i

static func setup(_player : Player, _direction : Vector2i) -> PlayerMoveEvent:
	var event : PlayerMoveEvent = PlayerMoveEvent.new()
	event.player_id = MultiplayerManager.player_to_peer_id[_player] 
	event.direction = _direction
	event.time = Aligner.get_time()
	return event
