class_name StructureZoner
extends Zoner

func zone(chunk : Chunk) -> void:
	var num_structures_in_area : int = 3
	var subareas : Array[Area]
	
	for area : Area in chunk.areas:
		var unaccounted_tiles : Array[Vector2i] = area.get_coordinates().duplicate()
		var unexpanded_tiles_in_subarea : Dictionary = {}
		
		for i in range(num_structures_in_area):
			var subarea := Area.new()
			subareas.append(subarea)
			
			var starting_tile : Vector2i = unaccounted_tiles.pick_random()
			
			unaccounted_tiles.erase(starting_tile)
			subarea.add_coordinate(starting_tile)
			unexpanded_tiles_in_subarea[subarea] = [starting_tile]
		
		while not unaccounted_tiles.is_empty():
			for subarea : Area in unexpanded_tiles_in_subarea:
				var new_unexpanded_tiles : Array = []
				for tile_to_expand : Vector2i in unexpanded_tiles_in_subarea[subarea]:
					
					var neighbors : Array[Vector2i] = Psyoko.get_coordinate_neighbors(tile_to_expand)
					for neighbor_coord in neighbors:
						if unaccounted_tiles.has(neighbor_coord):
							subarea.add_coordinate(neighbor_coord)
							new_unexpanded_tiles.append(neighbor_coord)
							
							unaccounted_tiles.erase(neighbor_coord)
					
				unexpanded_tiles_in_subarea[subarea] = new_unexpanded_tiles
	
	# TODO: todd rectangle
	
	chunk.subareas = subareas
	chunk.generation_stage = Chunk.GENERATION_STAGE.STRUCTURES
