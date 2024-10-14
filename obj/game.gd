class_name Game
extends Node

@onready var play_menu : PlayMenu = $"%PLAY-MENU"
@onready var server_menu : ServerMenu = $"%SERVER_MENU"
@onready var settings_menu : SettingsMenu = $"%SETTINGS-MENU"
@onready var leaderboard : Leaderboard = $"%LEADERBOARD"

func _ready():
	var args := Array(OS.get_cmdline_args())
	if args.has("-server"):
		MultiplayerManager.host_lobby(args.has("-lan"))
	elif args.has("-client"):
		var ip_arg_idx : int = args.find("-ip")
		var server_ip : String = ""
		if ip_arg_idx != -1:
			server_ip = args[ip_arg_idx + 1]
		server_menu.join_requested.emit(server_ip)
	
	if args.has("-client"):
		for bus_idx : int in range(0, AudioServer.bus_count):
			AudioServer.set_bus_mute(bus_idx, true)

	server_menu.host_requested.connect(
		func() -> void:
			MultiplayerManager.host_lobby()
			#server_menu.hide()
	)

	server_menu.join_requested.connect(
		func(server_ip : String) -> void:
			if server_ip.is_valid_ip_address():
				MultiplayerManager.ADDRESS = server_ip
			MultiplayerManager.join_lobby()
	)

	var cleanup_server_menu : Callable = func() -> void:
		server_menu.stop_animating()
		server_menu.hide()
		play_menu.show_menu()

	MultiplayerManager.received_network_message.connect(
		func handle_network_message(_sender_id : int, message : String, _args : Array) -> void:
			if message != "game/state_init": return
			cleanup_server_menu.call()
	)
	MultiplayerManager.hosted_lobby.connect(cleanup_server_menu)
	
	play_menu.play_requested.connect(
		func(player_name : String, player_color : Color) -> void:
			Aligner.submit_event(PlayerSpawnEvent.setup(MultiplayerManager.get_peer_id(), player_name))
			Aligner.submit_event(ObjectSetColorEvent.setup(MultiplayerManager.get_peer_id(), player_color))
			play_menu.hide()
			leaderboard.show()
			leaderboard.update()
	)
	play_menu.settings_requested.connect(
		func() -> void:
			play_menu.hide()
			settings_menu.show()
	)
	play_menu.change_server_requested.connect(
		func() -> void:
			play_menu.hide()
			server_menu.show()
	)
	settings_menu.settings_saved.connect(
		func() -> void:
			settings_menu.hide()
			play_menu.show()
	)
	
	play_menu.show_menu()

	# for box : Pushable in world.get_node("boxes").get_children():
	# 	UIDDB.register_object(box, hash(box.position))

var player_scene : PackedScene = load("res://obj/player/Player.tscn")

@onready var world : Node2D = $"%WORLD"
func make_player(peer_id : int, location : Vector2i = Vector2i.ZERO) -> Player:
	var player : Player = player_scene.instantiate()
	world.add_child(player)
	player.name = "P%s" % peer_id
	
	player.position = location
	player.chunk_coord = WorldData.tile_to_chunk_coords(player.position / Psyoko.TILE_SIZE)
	

	if peer_id == MultiplayerManager.get_peer_id():
		player.audio_listener.make_current()
		player.accept_input = true
		world.enter_chunk_by_coord(player.chunk_coord)

		player.moved.connect(
			func(direction : Vector2i) -> void:
			move_player(player, direction)
		)
		player.attacked.connect(
			func(direction : Vector2i, is_long : bool) -> void:
			player_attacks(player, direction, is_long)
		)
		player.passed_chunk_border.connect(
			func(coord : Vector2i) -> void:
			world.enter_chunk_by_coord(coord)
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
	play_menu.show_menu()
	leaderboard.hide()
