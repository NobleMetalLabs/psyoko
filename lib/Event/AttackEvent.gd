class_name AttackEvent
extends Event

var time : int
var player_id : int
var direction : Vector2i

static func setup(_player : Player, _direction : Vector2i) -> AttackEvent:
	var event : AttackEvent = AttackEvent.new()
	event.player_id = MultiplayerManager.player_to_peer_id[_player] 
	event.direction = _direction
	event.time = Aligner.get_time()
	return event
