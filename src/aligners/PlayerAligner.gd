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
	elif event is PlayerAttackEvent:
		_do_attack(event as PlayerAttackEvent)
	elif event is PlayerDeathEvent:
		_do_death(event as PlayerDeathEvent)

func undo_event(event : Event) -> void:
	if event is PlayerMoveEvent:
		_undo_movement(event as PlayerMoveEvent)
	elif event is PlayerSpawnEvent:
		_undo_spawn(event as PlayerSpawnEvent)
	elif event is PlayerAttackEvent:
		_undo_attack(event as PlayerAttackEvent)
	elif event is PlayerDeathEvent:
		_undo_death(event as PlayerDeathEvent)

func fast_forward_event(event : Event, time_seconds : float) -> void:
	if event is PlayerAttackEvent:
		_fast_forward_attack(event as PlayerAttackEvent, time_seconds)



func _do_movement(event : PlayerMoveEvent) -> void:
	var player = MultiplayerManager.peer_id_to_player[event.player_id]
	if player == null: return
	player.position += Vector2(event.direction) * Psyoko.TILE_SIZE

func _undo_movement(event : PlayerMoveEvent) -> void:
	var player = MultiplayerManager.peer_id_to_player[event.player_id]
	if player == null: return
	player.position -= Vector2(event.direction) * Psyoko.TILE_SIZE



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
	var player : Player = MultiplayerManager.peer_id_to_player[event.player_id]
	player.attack_sprite.attack(event.direction)
	
	for area in player.attack_area.get_overlapping_areas():
		if area is Player: Aligner.submit_event(PlayerDeathEvent.setup(area))

func _undo_attack(event : PlayerAttackEvent) -> void:
	MultiplayerManager.peer_id_to_player[event.player_id].attack_sprite.cancel()

func _fast_forward_attack(event : PlayerAttackEvent, time_seconds : float) -> void:
	MultiplayerManager.peer_id_to_player[event.player_id].attack_sprite.ff(time_seconds)



func _do_death(event : PlayerDeathEvent) -> void:
	var player : Player = MultiplayerManager.peer_id_to_player[event.player_id]
	player.hide()
	player.accept_input = false
	
	player.death_timer.start()
	#player.death_timer.timeout.connect(print.bind("menu")) # kill this

func _undo_death(event : PlayerDeathEvent) -> void:
	var player : Player = MultiplayerManager.peer_id_to_player[event.player_id]
	player.show()
	player.accept_input = true
	
	player.death_timer.stop()
