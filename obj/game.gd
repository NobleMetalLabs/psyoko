class_name Game
extends Node

@onready var play_menu : PlayMenu = $"%PLAY-MENU"
@onready var server_menu : ServerMenu = $"%SERVER_MENU"

# temporary
@onready var procgen = $"%WORLD".get_child(0)

func _ready():
	var args := Array(OS.get_cmdline_args())
	if args.has("-server"):
		MultiplayerManager.host_lobby(args.has("-lan"))
	elif args.has("-client"):
		var ip_arg_idx : int = args.find("-ip")
		var server_ip : String = ""
		if ip_arg_idx != -1:
			server_ip = args[ip_arg_idx + 1]
		play_menu.play_requested.emit("", true, server_ip)
	
	if args.has("-client"):
		for bus_idx : int in range(0, AudioServer.bus_count):
			AudioServer.set_bus_mute(bus_idx, true)

	if not MultiplayerManager.is_in_server():
		server_menu.show()

	server_menu.join_requested.connect(
		func(server_ip : String) -> void:
			if not server_ip.is_valid_ip_address(): return
			MultiplayerManager.ADDRESS = server_ip
			MultiplayerManager.join_lobby()
	)

	MultiplayerManager.received_network_message.connect(
		func handle_network_message(_sender_id : int, message : String, _args : Array) -> void:
		if message == "game/state_init":
			server_menu.stop_animating()
			server_menu.hide()
			play_menu.show()
	)
	
	play_menu.play_requested.connect(
		func(player_name : String) -> void:
			if not player_name.is_empty():
				MultiplayerManager.player_name = player_name
			Aligner.submit_event(PlayerSpawnEvent.setup(MultiplayerManager.get_peer_id()))
			play_menu.hide()
	)

	# for box : Pushable in world.get_node("boxes").get_children():
	# 	UIDDB.register_object(box, hash(box.position))

var player_scene : PackedScene = load("res://obj/player/Player.tscn")

@onready var world : Node2D = $"%WORLD"
func make_player(peer_id : int) -> Player:
	var player : Player = player_scene.instantiate()
	world.add_child(player)
	player.name = "P%s" % peer_id

	if peer_id == MultiplayerManager.get_peer_id():
		player.audio_listener.make_current()
		player.accept_input = true

	player.moved.connect(
		func(direction : Vector2i) -> void:
		move_player(player, direction)
	)
	player.attacked.connect(
		func(direction : Vector2i, is_long : bool) -> void:
		player_attacks(player, direction, is_long)
	)
	return player

func move_player(player : Player, direction : Vector2) -> void:
	var pushed_objects = player.collision_check(direction)
	if not pushed_objects.is_empty() and pushed_objects.back() is TileMapLayer: return
	
	var flipped : Vector2 = Vector2(direction.x, -direction.y)
	Aligner.submit_event(ObjectMoveEvent.setup(player, flipped))
	for pushed_object in pushed_objects:
		Aligner.submit_event(ObjectMoveEvent.setup(pushed_object, flipped))

func player_attacks(player : Player, direction : Vector2, is_long : bool) -> void:
	Aligner.submit_event(PlayerAttackEvent.setup(player, direction, is_long))

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug"):
		var event : Event = ObjectMoveEvent.setup(MultiplayerManager.get_local_player(), Vector2i.RIGHT)
		event.time = 0
		Aligner.submit_event(event)

func you_died() -> void:
	play_menu.show()

func update_leaderboard() -> void:
	for player_id : int in MultiplayerManager.peer_ids:
		if not UIDDB.has_uid(player_id): continue
		var player : Player = UIDDB.object(player_id)
		print("%s Kills: %d" % [player.name, player.number_of_kills])
