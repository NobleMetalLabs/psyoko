class_name Leaderboard
extends Control

@onready var label_container : VBoxContainer = $"%LABEL_CONTAINER"
@onready var flex_label : Label = $"%FlexLabel"

func update() -> void:
	var sorted_players : Array[Player]
	for player_id : int in MultiplayerManager.peer_ids:
		if not UIDDB.has_uid(player_id): continue
		var player : Player = UIDDB.object(player_id)
		
		#print("%s Kills: %d" % [player.name, player.number_of_kills])
		if player.accept_input: sorted_players.push_back(player)
	
	sorted_players.sort_custom(func(a: Player, b: Player): return a.number_of_kills > b.number_of_kills)
	
	var local_player : Player = MultiplayerManager.get_local_player()
	
	for leaderboard_index : int in range(10):
		var leaderboard_label : Label = label_container.get_child(leaderboard_index + 2)
		if leaderboard_index >= sorted_players.size():
			leaderboard_label.hide()
			continue
		
		leaderboard_label.show()
		var ranked_player : Player = sorted_players[leaderboard_index]
		leaderboard_label.text = generate_entry(ranked_player, leaderboard_index + 1)
		
		if ranked_player == local_player: leaderboard_label.modulate = Color.YELLOW
		else: leaderboard_label.modulate = Color.WHITE
	
	var local_player_rank = sorted_players.find(local_player)
	if local_player_rank < 10: flex_label.hide()
	else:
		flex_label.show()
		flex_label.text = generate_entry(local_player, local_player_rank + 1)

func generate_entry(player : Player, rank : int) -> String:
	var truncated_name : String = player.name.c_escape()
	if truncated_name.length() > 14: truncated_name = truncated_name.left(11) + "..."
	
	return "#%-2d %-14s %3d" % [rank, truncated_name, player.number_of_kills]
