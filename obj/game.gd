class_name Game
extends Node2D

var players : Array[Player] = []
var player_scene : PackedScene = load("res://obj/player/Player.tscn")
func make_player(peer_id : int) -> Player:
	var player : Player = player_scene.instantiate()
	self.add_child(player)
	player.name = "P%s" % peer_id
	players.append(player)

	if peer_id != MultiplayerManager.get_peer_id():
		player.accept_input = false

	player.moved.connect(
		func(direction : Vector2i) -> void:
		move_player(player, direction)
	)
	player.attacked.connect(
		func(direction : Vector2i) -> void:
		player_attacks(player, direction)
	)
	return player

func move_player(player : Player, direction : Vector2) -> void:
	var flipped : Vector2 = Vector2(direction.x, -direction.y)
	Aligner.submit_event(PlayerMoveEvent.setup(player, flipped))

func player_attacks(player : Player, direction : Vector2) -> void:
	Aligner.submit_event(PlayerAttackEvent.setup(player, direction))

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug"):
		var event : Event = PlayerMoveEvent.setup(MultiplayerManager.get_local_player(), Vector2i.RIGHT)
		event.time = 0
		Aligner.submit_event(event)
