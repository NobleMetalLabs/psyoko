extends Camera2D

const MAX_TARGET_DISTANCE : int = 250
var INTERPOLATION_RATE : float = 20

func _process(_delta) -> void:
	var my_player : Player = MultiplayerManager.get_local_player()

	if my_player == null: return

	var nearest_player : Player = my_player
	var nearest_player_distance : float = MAX_TARGET_DISTANCE ** 2
	for player in MultiplayerManager.peer_id_to_player.values():
		if player == my_player:
			continue
		var player_distance : float = player.global_position.distance_squared_to(my_player.global_position)
		if player_distance < nearest_player_distance:
			nearest_player = player
			nearest_player_distance = player_distance

	var view_rect : Rect2 = Rect2() 
	view_rect.position = my_player.global_position
	view_rect = view_rect.expand(nearest_player.global_position)
	view_rect = view_rect.expand(my_player.global_position)
	view_rect = view_rect.grow(25)

	set_to_rect(view_rect)

@onready var viewport_rect = get_viewport_rect()
func set_to_rect(rect : Rect2) -> void:
	if rect.size.is_zero_approx(): return
	var cam_pos : Vector2 = rect.get_center()
	var _cam_scale : Vector2 = viewport_rect.size / rect.size
	var cam_zoom : Vector2 = Vector2.ONE * (_cam_scale.x if _cam_scale.x < _cam_scale.y else _cam_scale.y)

	cam_zoom = cam_zoom.clamp(Vector2.ZERO, Vector2.ONE * 1.25)

	self.position = self.position.move_toward(cam_pos, INTERPOLATION_RATE)
	self.zoom = self.zoom.move_toward(cam_zoom, INTERPOLATION_RATE / 100)

