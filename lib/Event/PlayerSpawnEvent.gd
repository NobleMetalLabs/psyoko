class_name PlayerSpawnEvent
extends Event

var time : int
var player_id : int
var location : Vector2i

func _to_string() -> String:
	return "PlayerSpawnEvent(%s, %s, %s)" % [time, player_id, location]

static func setup(peer_id : int, _location : Vector2i = Vector2i.ZERO) -> PlayerSpawnEvent:
	var event : PlayerSpawnEvent = PlayerSpawnEvent.new()
	event.player_id = peer_id
	event.time = Aligner.get_time()
	if _location == Vector2i.ZERO:
		seed(peer_id * event.time)
		_location = Vector2i(randi_range(0, 10), randi_range(0, 10)) * Psyoko.TILE_SIZE
		_location += Vector2i.ONE * (Psyoko.TILE_SIZE / 2)
	event.location = _location 
	return event
