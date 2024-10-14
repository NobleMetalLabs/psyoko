extends Node2D

func _ready() -> void:
	scale = Psyoko.SCREEN_SCALE
	MultiplayerManager.received_network_message.connect(
		func handle_network_message(_sender_id : int, message : String, args : Array) -> void:
		if message == "game/state_init":
			initialize_world(args[1])
	)

func initialize_world(world_seed : int = 0) -> void:
	if world_seed == 0: WorldData.world_seed = randi()
	else: WorldData.world_seed = world_seed
	
	WorldData.biome_zoner.biome_noise.seed = WorldData.world_seed

var rendered_chunks : Array[Chunk]
func enter_chunk_by_coord(chunk_coord : Vector2i) -> void:
	var load_range : int = 1
	var visible_chunks : Array[Chunk]
	for dx in range(-load_range, load_range+1):
		for dy in range(-load_range, load_range+1):
			var chunk_in_question = WorldData.get_chunk(chunk_coord + Vector2i(dx,dy), Chunk.GENERATION_STAGE.PAINTED)
			
			visible_chunks.append(chunk_in_question)
			if not rendered_chunks.has(chunk_in_question):
				render_chunk(chunk_in_question)
				rendered_chunks.append(chunk_in_question)

@onready var biome_layer : TileMapLayer = $"%GEN-Biome"
@onready var subarea_layer : TileMapLayer = $"%GEN-Subareas"
@onready var structure_layer : TileMapLayer = $"%GEN-Structures"
@onready var bg_layer : TileMapLayer = $"%Background"
func render_chunk(chunk : Chunk) -> void:
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

	for subarea : Area in chunk.subareas:
		for coord in subarea.get_coordinates():
			subarea_layer.set_cell(coord, 0, Vector2i(4, subarea.id % 10))

	for structure : Structure in chunk.structures:
		var bound_points : Array[Vector2i] = []
		for dx in range(structure.bounds.size.x):
			bound_points.append(Vector2i(dx, 0))
			bound_points.append(Vector2i(dx, structure.bounds.size.y - 1))
		for dy in range(structure.bounds.size.y):
			bound_points.append(Vector2i(0, dy))
			bound_points.append(Vector2i(structure.bounds.size.x - 1, dy))
		for point in bound_points:
			structure_layer.set_cell(structure.bounds.position + point, 0, Vector2i(1, 9))

	if chunk.unpainted_tiles.size() == 0:
		for dx in range(Psyoko.CHUNK_SIZE):
			for dy in range(Psyoko.CHUNK_SIZE):
				var t_coord = chunk.world_coordinates + Vector2i(dx, dy)
				bg_layer.set_cell(t_coord, 0, chunk.tile_paint_data.get_value(t_coord))
