class_name AreaZoner
extends Zoner

var chunk : Chunk
var relevant_chunks : Array[Chunk] = []
var relevant_tile_values : Dictionary = {} #[Vector2i, int]
var relevant_tile_chunks : Dictionary = {} #[Vector2i, Chunk]

func zone(_chunk : Chunk) -> void:
	chunk = _chunk
	_reset_tracked_chunks()

	var existing_areas : Array[Area] = chunk.areas
	for area in existing_areas:
		for coord in area.get_coordinates():
			relevant_tile_values.erase(coord)

	var new_areas : Array[Area] = []
	while relevant_tile_values.size() > 0:
		var new_area := Area.new()
		var first_coord : Vector2i = relevant_tile_values.keys().front()
		new_area.add_coordinate(first_coord)
		var area_value : int = relevant_tile_values[first_coord] 
		for coord_in_area in new_area.get_coordinates():
			var chunk_owner : Chunk = relevant_tile_chunks[coord_in_area]
			if not chunk_owner.areas.has(new_area):
				chunk_owner.areas.append(new_area)
			var neighbors : Array[Vector2i] = Psyoko.get_coordinate_neighbors(coord_in_area)
			for neighbor_coord in neighbors:
				if new_area.has_coordinate(neighbor_coord): continue
				if not neighbor_coord in relevant_tile_values.keys(): continue
				if relevant_tile_values[neighbor_coord] != area_value: continue
				new_area.add_coordinate(neighbor_coord)
				var vec_to_coord_from_chunk_owner : Vector2i = neighbor_coord - chunk_owner.world_coordinates
				var adjacent_relevant_chunk_vectors : Array[Vector2i] = []
				if vec_to_coord_from_chunk_owner.x == 0:
					adjacent_relevant_chunk_vectors.append(Vector2i.LEFT)
				if vec_to_coord_from_chunk_owner.x == Psyoko.CHUNK_SIZE - 1:
					adjacent_relevant_chunk_vectors.append(Vector2i.RIGHT)
				if vec_to_coord_from_chunk_owner.y == 0:
					adjacent_relevant_chunk_vectors.append(Vector2i.UP)
				if vec_to_coord_from_chunk_owner.y == Psyoko.CHUNK_SIZE - 1:
					adjacent_relevant_chunk_vectors.append(Vector2i.DOWN)
				for chunk_neighbor_vector in adjacent_relevant_chunk_vectors:
					var adjacent_chunk_coords : Vector2i = chunk_owner.chunk_coordinates + chunk_neighbor_vector
					var neighbor_chunk : Chunk = WorldData.get_chunk(adjacent_chunk_coords, Chunk.GENERATION_STAGE.BIOMES)
					add_relevant_chunk(neighbor_chunk, new_area)
					
		new_areas.append(new_area)
		_reset_tracked_chunks()

	#print("%s new areas made by chunk %s" % [new_areas.size(), chunk.world_coordinates])
	chunk.generation_stage = Chunk.GENERATION_STAGE.AREAS

func _reset_tracked_chunks() -> void:
	relevant_chunks.clear()
	relevant_tile_chunks.clear()
	relevant_tile_values.clear()
	add_relevant_chunk(chunk)

func add_relevant_chunk(new_chunk : Chunk, relevant_area : Area = null) -> void:
	if new_chunk in relevant_chunks: return
	relevant_chunks.append(new_chunk)

	var existing_areas : Array[Area] = []
	var accounted_for_coords : Array[Vector2i] = []
	for relevant_chunk in relevant_chunks:
		for area in relevant_chunk.areas:
			existing_areas.append(area)
	for area in existing_areas:
		for coord in area.get_coordinates():
			accounted_for_coords.append(coord)
	
	for dx : int in range(Psyoko.CHUNK_SIZE):
		for dy : int in range(Psyoko.CHUNK_SIZE):
			var coord : Vector2i = new_chunk.world_coordinates + Vector2i(dx, dy)
			if coord in accounted_for_coords: continue
			var value : int = new_chunk.biome_data.get_value(coord)
			if value == 0: continue
			relevant_tile_values[coord] = value
			relevant_tile_chunks[coord] = new_chunk
	
	if relevant_area == null: return
	new_chunk.areas.append(relevant_area)
