class_name BiomeZoner
extends Zoner

@export var biome_noise : FastNoiseLite

func zone(chunk : Chunk) -> void:
	for dx in range(Psyoko.CHUNK_SIZE):
		for dy in range(Psyoko.CHUNK_SIZE):
			var working_coord : Vector2i = chunk.world_coordinates + Vector2i(dx, dy)
			var noise_value : float = biome_noise.get_noise_2d(working_coord.x, working_coord.y)
			var biome_index : int = floor(remap(noise_value, -1, 1, 0, 4.99))
			if biome_index == 0: 
				biome_index = 1
			elif biome_index == 1:
				biome_index = 2
			elif biome_index == 2:
				biome_index = 0
			chunk.biome_data.set_value(working_coord, biome_index)
		
	chunk.generation_stage = Chunk.GENERATION_STAGE.BIOMES