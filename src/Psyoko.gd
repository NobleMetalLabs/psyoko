#class_name Psyoko
extends Node

const SCREEN_SCALE : int = 10

const TILE_SIZE : int = 16
const CHUNK_SIZE : int = 16

const MAX_TARGET_DISTANCE : int = 2 * CHUNK_SIZE * TILE_SIZE

func get_coordinate_neighbors(coord : Vector2i, include_diagonals : bool = false) -> Array[Vector2i]:
	var neighbors : Array[Vector2i] = []
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			if dx == 0 and dy == 0: continue
			if (dx != 0 and dy != 0):
				if not include_diagonals: continue
			neighbors.append(coord + Vector2i(dx, dy))
	return neighbors