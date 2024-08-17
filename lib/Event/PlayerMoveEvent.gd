class_name PlayerMoveEvent
extends Event

var time : int
var player_id : int
var direction : Vector2i
var additional_object_ids : Array

static func setup(_player : Player, _direction : Vector2i, _additional_objects : Array) -> PlayerMoveEvent:
	var event : PlayerMoveEvent = PlayerMoveEvent.new()
	event.player_id = MultiplayerManager.player_to_peer_id[_player] 
	event.direction = _direction
	event.additional_object_ids = _additional_objects
	event.time = Aligner.get_time()
	return event
