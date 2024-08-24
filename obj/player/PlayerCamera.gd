extends Camera2D

const SCREEN_PADDING : int = 2 * Psyoko.TILE_SIZE
const PAN_RATE : float = 0.5 * Psyoko.TILE_SIZE
const ZOOM_RATE : float = 0.01 
const MAX_ZOOM : float = 0.5

# TODO: Some functionality of the camera calculates based on viewport size, which may not equal window size due to window header, taskbar, etc.

func _process(_delta) -> void:
	var my_player : Player = MultiplayerManager.get_local_player()

	if my_player != null:
		if my_player.visible == true:
			do_live_cam(my_player)
			return
	do_dead_cam()

func do_live_cam(my_player : Player) -> void:
	var nearest_player : Player = my_player
	var nearest_player_distance : float = (Psyoko.MAX_TARGET_DISTANCE * Psyoko.SCREEN_SCALE) ** 2 
	for player_id in MultiplayerManager.peer_ids:
		if not UIDDB.has_uid(player_id): continue
		var player = UIDDB.object(player_id)
		if player == my_player: continue
		if not player.visible: continue
		var player_distance : float = player.global_position.distance_squared_to(my_player.global_position)
		if player_distance < nearest_player_distance:
			nearest_player = player
			nearest_player_distance = player_distance

	var view_rect : Rect2 = Rect2() 
	view_rect.position = my_player.global_position
	view_rect = view_rect.expand(nearest_player.global_position)
	view_rect = view_rect.expand(my_player.global_position)
	view_rect = view_rect.grow(SCREEN_PADDING * Psyoko.SCREEN_SCALE)

	set_to_rect(view_rect)

func do_dead_cam() -> void:
	self.zoom = self.zoom.move_toward(Vector2.ONE * 0.25, ZOOM_RATE / 100)

@onready var viewport_rect = get_viewport_rect()
func set_to_rect(rect : Rect2) -> void:
	if rect.size.is_zero_approx(): return
	var cam_pos : Vector2 = rect.get_center() 
	var _cam_scale : Vector2 = viewport_rect.size / rect.size
	var cam_zoom : Vector2 = Vector2.ONE * (_cam_scale.x if _cam_scale.x < _cam_scale.y else _cam_scale.y)

	cam_zoom = cam_zoom.clampf(0, MAX_ZOOM)

	self.position = self.position.move_toward(cam_pos, PAN_RATE * Psyoko.SCREEN_SCALE)
	self.zoom = self.zoom.move_toward(cam_zoom, ZOOM_RATE)
