class_name PlayerSpawnEvent
extends Event

var time : int
var player_id : int
var location : Vector2i

static func setup(peer_id : int, _location : Vector2i = Vector2i.ZERO) -> PlayerSpawnEvent:
	var event : PlayerSpawnEvent = PlayerSpawnEvent.new()
	event.player_id = peer_id
	event.time = Aligner.get_time()
	if _location == Vector2i.ZERO:
		seed(peer_id * event.time)
		_location = Vector2i(randi_range(0, 100), randi_range(0, 100))
	event.location = _location 
	return event

func do() -> void:
	var new_player : Player = Router.game.make_player(player_id)
	new_player.position = self.location
	MultiplayerManager.player_to_peer_id[new_player] = player_id
	MultiplayerManager.peer_id_to_player[player_id] = new_player

func undo() -> void:
	var player : Player = MultiplayerManager.peer_id_to_player[player_id]
	MultiplayerManager.player_to_peer_id.erase(player)
	MultiplayerManager.peer_id_to_player[player_id] = null
	if player != null:
		player.queue_free()