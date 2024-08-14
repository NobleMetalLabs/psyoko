class_name PlayerAligner
extends Node



func _ready():
	Aligner.do_event.connect(do_event)
	Aligner.undo_event.connect(undo_event)
	Aligner.fast_forward_event.connect(fast_forward_event)



func do_event(event : Event) -> void:
	if event is PlayerMoveEvent:
		_do_movement(event as PlayerMoveEvent)
	elif event is PlayerSpawnEvent:
		_do_spawn(event as PlayerSpawnEvent)

func undo_event(event : Event) -> void:
	if event is PlayerMoveEvent:
		_undo_movement(event as PlayerMoveEvent)
	elif event is PlayerSpawnEvent:
		_undo_spawn(event as PlayerSpawnEvent)

func fast_forward_event(event : Event, time_seconds : float) -> void:
	if event is PlayerAttackEvent:
		_fast_forward_attack(event as PlayerAttackEvent, time_seconds)



func _do_movement(event : PlayerMoveEvent) -> void:
	var player = MultiplayerManager.peer_id_to_player[event.player_id]
	if player == null: return
	player.position += Vector2(event.direction) * 5

func _undo_movement(event : PlayerMoveEvent) -> void:
	var player = MultiplayerManager.peer_id_to_player[event.player_id]
	if player == null: return
	player.position -= Vector2(event.direction) * 5



func _do_spawn(event : PlayerSpawnEvent) -> void:
	var new_player : Player = Router.game.make_player(event.player_id)
	new_player.position = event.location
	MultiplayerManager.player_to_peer_id[new_player] = event.player_id
	MultiplayerManager.peer_id_to_player[event.player_id] = new_player

func _undo_spawn(event : PlayerSpawnEvent) -> void:
	var player : Player = MultiplayerManager.peer_id_to_player[event.player_id]
	MultiplayerManager.player_to_peer_id.erase(player)
	MultiplayerManager.peer_id_to_player[event.player_id] = null
	if player != null:
		player.queue_free()



func _do_attack(event : PlayerAttackEvent) -> void:
	MultiplayerManager.peer_id_to_player[event.player_id].attack_sprite.attack(event.direction)

func _undo_attack(event : PlayerAttackEvent) -> void:
	MultiplayerManager.peer_id_to_player[event.player_id].attack_sprite.cancel()

func _fast_forward_attack(event : PlayerAttackEvent, time_seconds : float) -> void:
	MultiplayerManager.peer_id_to_player[event.player_id].attack_sprite.ff(time_seconds)
