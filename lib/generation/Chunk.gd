class_name Chunk
extends Resource

var chunk_coordinates : Vector2i
var world_coordinates : Vector2i
var biome_data : BiomeData
var tile_paint_data : TilePaintData
var areas : Array[Area]
var subareas : Array[Area]
var structures : Array[Structure]
var unpainted_tiles : Array[Vector2i] = []

var generation_stage : GENERATION_STAGE = GENERATION_STAGE.NONE
enum GENERATION_STAGE {
	NONE,
	BIOMES,
	AREAS,
	STRUCTURES,
	PAINTED,
}

func _init(coordinates : Vector2i) -> void:
	chunk_coordinates = coordinates
	world_coordinates = coordinates * Psyoko.CHUNK_SIZE
	biome_data = BiomeData.new()
	tile_paint_data = TilePaintData.new()
	areas = []
	subareas = []
	structures = []
	unpainted_tiles = []
	for dx in range(Psyoko.CHUNK_SIZE):
		for dy in range(Psyoko.CHUNK_SIZE):
			unpainted_tiles.append(world_coordinates + Vector2i(dx, dy))
