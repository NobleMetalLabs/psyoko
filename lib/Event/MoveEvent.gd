class_name MoveEvent
extends Event

var time : int
var player_id : int
var direction : Vector2i

static func setup(_player : Player, _direction : Vector2i) -> MoveEvent:
	var event : MoveEvent = MoveEvent.new()
	event.player_id = MultiplayerManager.player_to_peer_id[_player] 
	event.direction = _direction
	event.time = Aligner.get_time()
	return event