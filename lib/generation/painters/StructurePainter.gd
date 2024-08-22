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
		
		for dx in range(largest_pattern.get_size().x):
			for dy in range(largest_pattern.get_size().y):
				var pattern_cell := Vector2i(dx,dy)
				if not largest_pattern.has_cell(pattern_cell): continue
				
				var pattern_offset = structure.bounds.get_center() - (largest_pattern.get_size() / 2)
				var tile_coord = pattern_cell + pattern_offset
				
				if chunk.unpainted_tiles.has(tile_coord):
					chunk.tile_paint_data.set_value(tile_coord, largest_pattern.get_cell_atlas_coords(pattern_cell))
					chunk.unpainted_tiles.erase(tile_coord)
