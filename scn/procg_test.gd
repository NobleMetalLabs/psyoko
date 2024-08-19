extends Node2D

@onready var tml : TileMapLayer = self.get_children().back()
var map_size : Vector2i = Vector2i(256, 256)

var tile_size : int = 5

func _ready() -> void:
	var walk_points : Array[Vector2i] = []
	var current_point : Vector2i = Vector2i.ZERO
	var last_dir : Vector2i = Vector2i.UP
	var curr_dir : Vector2i = last_dir
	for i in range(0, 100):
		if randf_range(0, 1) < 0.125:
			#dir change
			var new_dir : Vector2i 
			if randf_range(0, 1) < 0.66:
				new_dir = curr_dir * -1
			else:
				new_dir = curr_dir
				
			last_dir = curr_dir
			curr_dir = new_dir

			curr_dir = Vector2i(Vector2(curr_dir).rotated(deg_to_rad([90, -90].pick_random())))
		
		current_point += curr_dir * tile_size

		if not current_point in walk_points:
			walk_points.append(current_point)

	for point in walk_points:
		fill_path(point)

func fill_path(point : Vector2i) -> void:
	var smalls : Array[Vector2i] = [
		Vector2i(0, 1),
		Vector2i(1, 1),
		Vector2i(0, 2),
		Vector2i(1, 2),
	]
	var bigs : Array[Vector2i] = [
		Vector2i(0, 3),
		Vector2i(1, 3),
		Vector2i(2, 3),
		Vector2i(0, 4),
		Vector2i(1, 4),
		Vector2i(2, 4),
		Vector2i(0, 5),
		Vector2i(1, 5),
		Vector2i(2, 5),
	]

	var half_size = floor(tile_size / 2.0)
	for dsx in range(-half_size, half_size + 1):
		for dsy in range(-half_size, half_size + 1):
			print(Vector2i(dsx, dsy))
			var dist = Vector2i(dsx, dsy).length_squared()
			print(dist)
			var dist_percent = remap(dist, 0, (half_size ** 2) * 2, 0, 1)
			print(dist_percent)
			if dist_percent < 0.4:
				tml.set_cell(point + Vector2i(dsx, dsy), 0, bigs.pick_random())
			elif dist_percent < 0.8:
				tml.set_cell(point + Vector2i(dsx, dsy), 0, smalls.pick_random())
			else:
				tml.set_cell(point + Vector2i(dsx, dsy), 0, Vector2i.ZERO)