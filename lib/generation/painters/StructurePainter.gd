class_name StructurePainter
extends Painter

@export var pattern_tile_set : TileSet
@onready var possible_patterns : Array[TileMapPattern]

func _ready():
	for i in range(pattern_tile_set.get_patterns_count()):
		possible_patterns.append(pattern_tile_set.get_pattern(i))

func paint(chunk : Chunk) -> void:
	for structure : Structure in chunk.structures:
		var largest_pattern : TileMapPattern = null
		var largest_size : int = 0
		
		for pattern : TileMapPattern in possible_patterns:
			var pattern_size = pattern.get_size()
			if pattern_size.x <= structure.bounds.size.x and pattern_size.y <= structure.bounds.size.y:
				if (pattern_size.length_squared() > largest_size):
					largest_size = pattern_size.length_squared()
					largest_pattern = pattern
		print("Chunk world coords %s" % chunk.world_coordinates)
		print("Structure bounds %s" % structure.bounds)
		print("Pattern size %s" % largest_pattern.get_size())
		for x in range(largest_pattern.get_size().x):
			for y in range(largest_pattern.get_size().y):
				var pattern_cell := Vector2i(x,y)
				var tile_coord = structure.bounds.position + pattern_cell
				
				#print("Checking tile %s" % tile_coord)
				if chunk.unpainted_tiles.has(tile_coord):
					#print("Attempting to paint tile %s with pattern cell %s" % [tile_coord, pattern_cell])
					if largest_pattern.has_cell(pattern_cell):
						chunk.tile_paint_data.set_value(tile_coord, largest_pattern.get_cell_atlas_coords(pattern_cell))
						chunk.unpainted_tiles.erase(tile_coord)
