class_name Box
extends Area2D

@onready var move_cast = $MoveCast
func collision_check(direction : Vector2) -> Array:
	move_cast.rotation = Vector2(direction).angle_to(Vector2i.RIGHT)
	move_cast.force_raycast_update()
	
	var pushed = []
	var collider = move_cast.get_collider()
	if collider is TileMapLayer: 
		pushed.append(collider)
	elif collider is Box or collider is Player:
		pushed.append(UIDDB.uid(collider))
		pushed.append_array(collider.collision_check(direction))
	
	return pushed
