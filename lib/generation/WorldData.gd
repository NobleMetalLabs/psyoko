#class_name WorldData
extends Node

var world_seed : int = 0
var chunks : Array[Chunk] = []
var _chunk_coords_to_chunks : Dictionary = {} #[Vector2i, Chunk]

@onready var biome_zoner : BiomeZoner = $"BiomeZoner"
@onready var area_zoner : AreaZoner = $"AreaZoner"
@onready var structure_zoner : StructureZoner = $"StructureZoner"

@onready var biome_painter : BiomePainter = $"BiomePainter"
@onready var area_painter : AreaPainter = $"AreaPainter"
@onready var structure_painter : StructurePainter = $"StructurePainter"

func _add_chunk(chunk : Chunk) -> void:
	chunks.append(chunk)
	_chunk_coords_to_chunks[chunk.chunk_coordinates] = chunk

func get_chunk(chunk_coords : Vector2i, minimum_stage : Chunk.GENERATION_STAGE) -> Chunk:
	#print("Getting chunk %s" % chunk_coords)
	var chunk : Chunk = _chunk_coords_to_chunks.get(chunk_coords, null)
	if chunk == null:
		chunk = Chunk.new(chunk_coords)
		_add_chunk(chunk)

	while(true):
		if chunk.generation_stage >= minimum_stage:
			break
		match chunk.generation_stage:
			Chunk.GENERATION_STAGE.NONE:
				biome_zoner.zone(chunk)
			Chunk.GENERATION_STAGE.BIOMES:
				area_zoner.zone(chunk)
			Chunk.GENERATION_STAGE.AREAS:
				structure_zoner.zone(chunk)
			Chunk.GENERATION_STAGE.STRUCTURES:
				structure_painter.paint(chunk)
				area_painter.paint(chunk)
				biome_painter.paint(chunk)
			Chunk.GENERATION_STAGE.PAINTED:
				break
			_:
				assert(false, "Invalid generation stage: %s" % chunk.generation_stage)
				break

	return chunk

func tile_to_chunk_coords(tile_coords : Vector2i) -> Vector2i:
	return (Vector2(tile_coords) / Psyoko.CHUNK_SIZE).floor()
