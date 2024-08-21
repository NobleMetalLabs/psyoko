class_name BiomePainter
extends Painter

#@export var biome_paint_noise : FastNoiseLite

# 1 = water
# 2 = farm
# 3 = forest
# 4 = mountain

func paint(chunk : Chunk) -> void:
	for tile_coord in chunk.unpainted_tiles.duplicate():
		var biome_index : int = chunk.biome_data.get_value(tile_coord)
		match(biome_index):
			0:
				paint_empty(chunk, tile_coord)
			1:
				paint_water(chunk, tile_coord)
			2:
				paint_farm(chunk, tile_coord)
			3:
				paint_forest(chunk, tile_coord)
			4:
				paint_mountain(chunk, tile_coord)
			_:
				assert(false, "Invalid biome index: " + str(biome_index))


	chunk.generation_stage = Chunk.GENERATION_STAGE.PAINTED

func paint_empty(chunk : Chunk, tile_coord : Vector2i) -> void:
	chunk.tile_paint_data.set_value(tile_coord, Vector2i(0, 0))
	chunk.unpainted_tiles.erase(tile_coord)

func paint_water(chunk : Chunk, tile_coord : Vector2i) -> void:
	chunk.tile_paint_data.set_value(tile_coord, Vector2i(1, 0))
	chunk.unpainted_tiles.erase(tile_coord)

func paint_farm(chunk : Chunk, tile_coord : Vector2i) -> void:
	var shrooms : Array[Vector2i] = [
		Vector2i(2, 9),
		Vector2i(3, 8),
		Vector2i(3, 9),
	]
	if randf() < 0.25:
		chunk.tile_paint_data.set_value(tile_coord, shrooms.pick_random())
	chunk.unpainted_tiles.erase(tile_coord)

func paint_forest(chunk : Chunk, tile_coord : Vector2i) -> void:
	var trees : Array[Vector2i] = [
		Vector2i(4, 8),
		Vector2i(5, 8),
	]
	if randf() < 0.25:
		chunk.tile_paint_data.set_value(tile_coord, trees.pick_random())
	chunk.unpainted_tiles.erase(tile_coord)

func paint_mountain(chunk : Chunk, tile_coord : Vector2i) -> void:
	var rocks : Array[Vector2i] = [
		Vector2i(2, 6),
		Vector2i(2, 7),
		Vector2i(3, 6),
		Vector2i(3, 7),
	]
	if randf() < 0.5:
		chunk.tile_paint_data.set_value(tile_coord, rocks.pick_random())
	chunk.unpainted_tiles.erase(tile_coord)
