class_name PlayerSpawnEvent
extends Event

var player_id : int
var location : Vector2i
var username : String

func _to_string() -> String:
	return "PlayerSpawnEvent(%s, %s, %s)" % [time, player_id, location]

static func setup(peer_id : int, _username : String, _location : Vector2i = Vector2i.ZERO) -> PlayerSpawnEvent:
	var event : PlayerSpawnEvent = PlayerSpawnEvent.new()
	event.player_id = peer_id
	event.time = Aligner.get_time()
	if _location == Vector2i.ZERO:
		var debug_range = Psyoko.CHUNK_SIZE * 2
		_location = Vector2i(randi_range(-debug_range, debug_range), randi_range(-debug_range, debug_range)) * Psyoko.TILE_SIZE
		_location += Vector2i.ONE * (Psyoko.TILE_SIZE / 2)
	
	event.location = _location
	event.username = _username
	return event
