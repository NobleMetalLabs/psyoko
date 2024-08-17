class_name Game
extends Node

func _ready():
	var args := Array(OS.get_cmdline_args())
	if args.has("-client"):
		for bus_idx : int in range(0, AudioServer.bus_count):
			AudioServer.set_bus_mute(bus_idx, true)
	
	# TEMPORARY SOLUTION
	for box : Box in world.get_node("boxes").get_children():
		UIDDB.register_object(box, hash(box.position))

var players : Array[Player] = []
var player_scene : PackedScene = load("res://obj/player/Player.tscn")

@onready var world : Node2D = $"%WORLD"
func make_player(peer_id : int) -> Player:
	var player : Player = player_scene.instantiate()
	world.add_child(player)
	player.name = "P%s" % peer_id
	players.append(player)

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
	Aligner.submit_event(PlayerMoveEvent.setup(player, flipped, pushed_objects))

func player_attacks(player : Player, direction : Vector2, is_long : bool) -> void:
	Aligner.submit_event(PlayerAttackEvent.setup(player, direction, is_long))

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug"):
		var event : Event = PlayerMoveEvent.setup(MultiplayerManager.get_local_player(), Vector2i.RIGHT, [])
		event.time = 0
		Aligner.submit_event(event)
