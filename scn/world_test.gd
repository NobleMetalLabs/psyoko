extends Node2D

@onready var tile_map : Node2D = $TileMap
@onready var biome_layer : TileMapLayer = tile_map.get_child(0)
var map_size : Vector2i = Vector2i(256, 256)

@export var biome_noise : FastNoiseLite

func _ready() -> void:

	biome_noise.seed = randi()

	for x in range(map_size.x):
		for y in range(map_size.y):
			var tile_idx : int = floor(remap(biome_noise.get_noise_2d(x, y), -1, 1, 1, 4))
			biome_layer.set_cell(Vector2i(x, y), 0, index_to_atlas_coord(tile_idx))

	var regions : Array[Array] = calculate_regions()
	fill_regions(regions)

func index_to_atlas_coord(index : int) -> Vector2i:
	var tileset_source : TileSetSource
	for source_idx : int in range(0, biome_layer.tile_set.get_source_count()):
		tileset_source = biome_layer.tile_set.get_source(source_idx)
		var tile_count : int = tileset_source.get_tiles_count()
		if index < tile_count:
			break
		else:
			index -= tile_count

	var grid_size : Vector2i = tileset_source.get_atlas_grid_size()
	var atlas_coord : Vector2i = Vector2i(index % grid_size.x, index / grid_size.x)

	return atlas_coord

func calculate_regions() -> Array[Array]:
	var regions : Array[Array] = []
	for tile_index : int in range(1, 4):
		var coords_of_tile = biome_layer.get_used_cells_by_id(0, index_to_atlas_coord(tile_index))
		while coords_of_tile.size() > 0:
			var new_region : Array[Vector2i] = [coords_of_tile.pop_front()]
			for tile_coords in new_region:
				var neighbors : Array[Vector2i] = Psyoko.get_coordinate_neighbors(tile_coords)
				for cell_coords in neighbors:
					if cell_coords in new_region: continue
					if cell_coords in coords_of_tile:
						new_region.append(cell_coords)
						coords_of_tile.erase(cell_coords)
			regions.append(new_region)

	# for region in regions:
	# 	print("[%s x %s]" % [biome_layer.get_cell_atlas_coords(region.front()), region.size()])

	return regions

func fill_regions(regions : Array[Array]) -> void:
	for region in regions:
		_fill_region(region)

func _fill_region(region : Array[Vector2i]) -> void:
	var region_types : Dictionary = {
		Vector2i(0, 0): "path",
		Vector2i(1, 0): "water",
		Vector2i(2, 0): "flowers",
		Vector2i(0, 1): "orchard",
		Vector2i(1, 1): "hedgemaze",
	}
	var region_type_coord : Vector2i = biome_layer.get_cell_atlas_coords(region.front())
	var region_type : String = region_types[region_type_coord]
	match(region_type):
		# "path":
		# 	_fill_path_region(region)
		"water":
			_fill_water_region(region)
		"flowers":
			_fill_flowers_region(region)
		"orchard":
			_fill_orchard_region(region)
		# "hedgemaze":
		# 	_fill_hedgemaze_region(region)
 
@onready var background_layer : TileMapLayer = tile_map.get_child(1)
@onready var foreground_layer : TileMapLayer = tile_map.get_child(2)

func _fill_water_region(region : Array[Vector2i]) -> void:
	for tile_coords in region:
		background_layer.set_cell(tile_coords, 0, Vector2i(1, 0))
		foreground_layer.erase_cell(tile_coords)

func _fill_flowers_region(region : Array[Vector2i]) -> void:
	for tile_coords in region:
		background_layer.set_cell(tile_coords, 0, Vector2i(0, 0))
		foreground_layer.set_cell(tile_coords, 0, Vector2i(3, 9))
		
func _fill_orchard_region(region : Array[Vector2i]) -> void:
	for tile_coords in region:
		background_layer.set_cell(tile_coords, 0, Vector2i(0, 0))
		foreground_layer.set_cell(tile_coords, 0, Vector2i(4, 8))