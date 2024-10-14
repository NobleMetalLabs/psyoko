class_name PlayerAligner
extends Node



func _ready():
	Aligner.do_event.connect(do_event)
	Aligner.undo_event.connect(undo_event)
	Aligner.fast_forward_event.connect(fast_forward_event)
	
	MultiplayerManager.received_network_message.connect(
		func handle_network_message(_sender_id : int, message : String, args : Array) -> void:
		if message == "game/state_init":
			init_players(args[1])
	)

func init_players(pi2p : Dictionary):
	for player_id in pi2p:
		_do_spawn(PlayerSpawnEvent.setup(player_id, pi2p[player_id]))

func do_event(event : Event) -> void:
	if event is PlayerSpawnEvent:
		_do_spawn(event as PlayerSpawnEvent)
	elif event is PlayerAttackEvent:
		_do_attack(event as PlayerAttackEvent)
	elif event is PlayerDeathEvent:
		_do_death(event as PlayerDeathEvent)

func undo_event(event : Event) -> void:
	if event is PlayerSpawnEvent:
		_undo_spawn(event as PlayerSpawnEvent)
	elif event is PlayerAttackEvent:
		_undo_attack(event as PlayerAttackEvent)
	elif event is PlayerDeathEvent:
		_undo_death(event as PlayerDeathEvent)

func fast_forward_event(event : Event, time_seconds : float) -> void:
	if event is PlayerAttackEvent:
		_fast_forward_attack(event as PlayerAttackEvent, time_seconds)



func _do_spawn(event : PlayerSpawnEvent) -> void:
	var player : Player = Router.game.make_player(event.player_id, event.location)
	
	player.death_timer.timeout.connect(_actually_do_death.bind(player))

	UIDDB.register_object(player, event.player_id)
	Router.game.leaderboard.update()

func _undo_spawn(event : PlayerSpawnEvent) -> void:
	var player : Player = UIDDB.object(event.player_id)
		
	player.death_timer.timeout.disconnect(_actually_do_death.bind(player))
	
	UIDDB.unregister_object(player)
	if player != null:
		player.queue_free()
	Router.game.leaderboard.update()

func _do_attack(event : PlayerAttackEvent) -> void:
	var player : Player = UIDDB.object(event.player_id)
	player.attack_base.rotation = Vector2(event.direction).angle_to(Vector2i.RIGHT)
	player.attack_sprite.attack(event.direction, event.is_long)
	
	var attack_casts : Array[RayCast2D] = []
	if event.is_long: attack_casts.append(player.long_attack_cast)
	else: attack_casts.append_array(player.normal_attack_holder.get_children())
	
	for cast : RayCast2D in attack_casts:
		cast.force_raycast_update()
		while cast.get_collider() is Player:
			
			cast.force_raycast_update()
			var attacked_player : Player = cast.get_collider()
			if attacked_player == null: continue
			cast.add_exception(attacked_player)
			
			var local_player = MultiplayerManager.get_local_player()
			if local_player != attacked_player and local_player != player: continue
			if not attacked_player.visible: continue
			if attacked_player == player: continue
			Aligner.submit_event(PlayerDeathEvent.setup(attacked_player, player))
		
		cast.clear_exceptions()

func _undo_attack(event : PlayerAttackEvent) -> void:
	UIDDB.object(event.player_id).attack_sprite.cancel()

func _fast_forward_attack(event : PlayerAttackEvent, time_seconds : float) -> void:
	UIDDB.object(event.player_id).attack_sprite.ff(time_seconds)



func _do_death(event : PlayerDeathEvent) -> void:
	var player : Player = UIDDB.object(event.player_id)
	if not player.visible: return
	
	player.hide()
	player.accept_input = false
	player.is_alive = false
	player.collision_shape.set_deferred("disabled", true)
	
	player.death_timer.start(2)
	
	var killer : Player = UIDDB.object(event.killer_id)
	killer.number_of_kills += 1
	
	Router.game.leaderboard.update()

func _actually_do_death(player : Player) -> void:
	if player == MultiplayerManager.get_local_player():
		Router.game.you_died()

	UIDDB.unregister_object(player)
	player.queue_free()

func _undo_death(event : PlayerDeathEvent) -> void:
	var player : Player = UIDDB.object(event.player_id)
	if player.visible: return
	
	player.show()
	player.accept_input = true
	player.is_alive = true
	player.collision_shape.set_deferred("disabled", false)
	
	player.death_timer.stop()
	
	var killer : Player = UIDDB.object(event.killer_id)
	killer.number_of_kills -= 1
	
	Router.game.leaderboard.update()

func _fast_forward_death(event : PlayerDeathEvent, time_seconds : float) -> void:
	var player : Player = UIDDB.object(event.player_id)
	if not player.visible: return

	player.death_timer.start(player.death_timer.time_left - time_seconds)
