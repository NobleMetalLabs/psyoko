class_name PlayerDeathEvent
extends Event

var time : int
var player_id : int
var killer_id : int

static func setup(_player : Player, _killer : Player) -> PlayerDeathEvent:
	var event : PlayerDeathEvent = PlayerDeathEvent.new()
	event.player_id = UIDDB.uid(_player) 
	event.killer_id = UIDDB.uid(_killer)
	event.time = Aligner.get_time()
	return event
