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
	var new_player : Player = Router.game.make_player(event.player_id)
	new_player.position = event.location
	
	UIDDB.register_object(new_player, event.player_id)
	Router.game.players.append(new_player)
	

func _undo_spawn(event : PlayerSpawnEvent) -> void:
	var player : Player = UIDDB.object(event.player_id)
		
	UIDDB.unregister_object(player)
	if player != null:
		Router.game.players.erase(player)
		player.queue_free()



func _do_attack(event : PlayerAttackEvent) -> void:
	var player : Player = UIDDB.object(event.player_id)
	player.attack_sprite.attack(event.direction, event.is_long)
	
	if not event.is_long:
		for cast : RayCast2D in player.normal_attack_holder.get_children():
			cast.force_raycast_update()
			while cast.get_collider() is Player:
				var attacked_player : Player = cast.get_collider()
				if attacked_player.visible:
					Aligner.submit_event(PlayerDeathEvent.setup(attacked_player, player))
				
				cast.add_exception(attacked_player)
				cast.force_raycast_update()
			
			cast.clear_exceptions()
		
	else:
		player.long_attack_cast.force_raycast_update()
		while player.long_attack_cast.get_collider() is Player:
			var attacked_player = player.long_attack_cast.get_collider()
			if attacked_player.visible:
				Aligner.submit_event(PlayerDeathEvent.setup(attacked_player, player))
			
			player.long_attack_cast.add_exception(attacked_player)
			player.long_attack_cast.force_raycast_update()
		
		player.long_attack_cast.clear_exceptions()

func _undo_attack(event : PlayerAttackEvent) -> void:
	UIDDB.object(event.player_id).attack_sprite.cancel()

func _fast_forward_attack(event : PlayerAttackEvent, time_seconds : float) -> void:
	UIDDB.object(event.player_id).attack_sprite.ff(time_seconds)



func _do_death(event : PlayerDeathEvent) -> void:
	var player : Player = UIDDB.object(event.player_id)
	if not player.visible: return
	
	player.hide()
	player.accept_input = false
	player.collision_shape.set_deferred("disabled", true)
	
	player.death_timer.start()
	#player.death_timer.timeout.connect(print.bind("menu")) # kill this
	
	var killer : Player = UIDDB.object(event.killer_id)
	killer.number_of_kills += 1
	
	Router.game.update_leaderboard()

func _undo_death(event : PlayerDeathEvent) -> void:
	var player : Player = UIDDB.object(event.player_id)
	if player.visible: return
	
	player.show()
	player.accept_input = true
	player.collision_shape.set_deferred("disabled", false)
	
	player.death_timer.stop()
	
	var killer : Player = UIDDB.object(event.killer_id)
	killer.number_of_kills -= 1
	
	Router.game.update_leaderboard()
