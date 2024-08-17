class_name PlayerDeathEvent
extends Event

var time : int
var player_id : int

static func setup(_player : Player) -> PlayerDeathEvent:
	var event : PlayerDeathEvent = PlayerDeathEvent.new()
	event.player_id = UIDDB.id(_player) 
	event.time = Aligner.get_time()
	return event
