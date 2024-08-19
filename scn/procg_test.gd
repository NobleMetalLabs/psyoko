extends Node2D

func _ready():

	WorldData.biome_zoner.biome_noise.seed = randi()

	var gen_size : int = 0
	for dx in range(-gen_size, gen_size + 1):
		for dy in range(-gen_size, gen_size + 1):
			WorldData.get_chunk(Vector2i(dx, dy), Chunk.GENERATION_STAGE.AREAS)

	var biome_layer : TileMapLayer = $"GEN-Biome"
	var bg_layer : TileMapLayer = $"Background"
	for chunk in WorldData.chunks:
		for dx in range(Psyoko.CHUNK_SIZE):
			for dy in range(Psyoko.CHUNK_SIZE):
				var working_coord : Vector2i = chunk.world_coordinates + Vector2i(dx, dy)
				var biome_index : int = chunk.biome_data.get_value(working_coord)
				biome_layer.set_cell(working_coord, 0, Vector2i(biome_index, 0))

				var vec_to_coord_from_chunk_owner : Vector2i = working_coord - chunk.world_coordinates
				if vec_to_coord_from_chunk_owner.x == 0 or \
					vec_to_coord_from_chunk_owner.x == Psyoko.CHUNK_SIZE - 1 or \
					vec_to_coord_from_chunk_owner.y == 0 or \
					vec_to_coord_from_chunk_owner.y == Psyoko.CHUNK_SIZE - 1:
					bg_layer.set_cell(working_coord, 0, Vector2i(5, 0))

	bg_layer.set_cell(Vector2i(0, 0), 0, Vector2i(5, 8))