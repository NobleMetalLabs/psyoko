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

func do() -> void:
	MultiplayerManager.peer_id_to_player[player_id].attack_sprite.attack(direction)

func undo() -> void:
	MultiplayerManager.peer_id_to_player[player_id].attack_sprite.cancel()

func fast_forward(_current_time : int) -> void:
	var time_seconds : float = (_current_time - time) / 1000.0
	MultiplayerManager.peer_id_to_player[player_id].attack_sprite.ff(time_seconds)

