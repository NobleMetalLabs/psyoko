class_name StructureZoner
extends Zoner

func zone(chunk : Chunk) -> void:
	var new_subareas : Array[Area]
	#var existing_subareas : Array[Area] = []
	
	for area : Area in chunk.areas:
		var area_existing_subareas : Array[Area] = area.get_subareas()
		if area_existing_subareas.size() > 0: 
			#existing_subareas.append_array(area_existing_subareas)
			continue

		var num_structures_in_area = round(area.get_coordinates().size() / 1000.0) + 1
		var unaccounted_tiles : Array[Vector2i] = area.get_coordinates().duplicate()
		var unexpanded_tiles_in_subarea : Dictionary = {}
		var chunks_entered_by_subarea : Dictionary = {}
		
		for i in range(num_structures_in_area):
			var subarea := Area.new()
			subarea.id = i
			new_subareas.append(subarea)
			area.add_subarea(subarea)
			subarea.parent_area = area
			
			var starting_tile : Vector2i = unaccounted_tiles.pick_random()
			
			unaccounted_tiles.erase(starting_tile)
			subarea.add_coordinate(starting_tile)
			unexpanded_tiles_in_subarea[subarea] = [starting_tile]
			
			var first_chunk_coords : Vector2i = WorldData.tile_to_chunk_coords(starting_tile)
			chunks_entered_by_subarea[subarea] = [first_chunk_coords]
			WorldData.get_chunk(first_chunk_coords, Chunk.GENERATION_STAGE.NONE).subareas.append(subarea)
			#print("Starting tile: Added subarea %s to chunk %s" % [subarea.id, first_chunk_coords])
		
		while not unaccounted_tiles.is_empty():
			for subarea : Area in unexpanded_tiles_in_subarea:
				var new_unexpanded_tiles : Array = []
				for tile_to_expand : Vector2i in unexpanded_tiles_in_subarea[subarea]:
					
					var relevant_chunk_coords : Vector2i = WorldData.tile_to_chunk_coords(tile_to_expand)
					if not chunks_entered_by_subarea[subarea].has(relevant_chunk_coords):
						chunks_entered_by_subarea[subarea].append(relevant_chunk_coords)
						WorldData.get_chunk(relevant_chunk_coords, Chunk.GENERATION_STAGE.NONE).subareas.append(subarea)
						#print("Added subarea %s to chunk %s" % [subarea.id, relevant_chunk_coords])
					
					var neighbors : Array[Vector2i] = Psyoko.get_coordinate_neighbors(tile_to_expand)
					for neighbor_coord in neighbors:
						if unaccounted_tiles.has(neighbor_coord):
							subarea.add_coordinate(neighbor_coord)
							new_unexpanded_tiles.append(neighbor_coord)
							
							unaccounted_tiles.erase(neighbor_coord)
					
				unexpanded_tiles_in_subarea[subarea] = new_unexpanded_tiles
	
	var new_structures : Array[Structure] = []
	for subarea : Area in new_subareas:
		var largest_rect : Rect2i = _largest_rect_in_subarea(subarea)
		var new_struct := Structure.new(largest_rect, randi_range(0, 10), subarea)
		new_structures.append(new_struct)
		subarea.add_structure(new_struct)
		
		var tl : Vector2i = WorldData.tile_to_chunk_coords(new_struct.bounds.position)
		var br : Vector2i = WorldData.tile_to_chunk_coords(new_struct.bounds.position + new_struct.bounds.size - Vector2i(1,1))
		
		for dx in range(tl.x, br.x + 1):
			for dy in range(tl.y, br.y + 1):
				WorldData.get_chunk(Vector2i(dx, dy), Chunk.GENERATION_STAGE.NONE).structures.append(new_struct)

	#print("%s new subareas made by chunk %s" % [new_subareas.size(), chunk.world_coordinates])
	#print("%s new structures made by chunk %s" % [new_structures.size(), chunk.world_coordinates])

	chunk.generation_stage = Chunk.GENERATION_STAGE.STRUCTURES

func _largest_rect_in_subarea(subarea : Area) -> Rect2i:
	var largest_rect := Rect2i()
	for start_pos : Vector2i in subarea.get_coordinates():
		# go all the way down
		var height = 1
		while subarea.has_coordinate(start_pos + Vector2i(0, height)): height += 1
		
		# try to expand right until fail
		var right_width = 1
		while true:
			var hit_edge = false
			for h in range(height):
				if not subarea.has_coordinate(start_pos + Vector2i(right_width, h)): hit_edge = true
			if hit_edge: break
			right_width += 1
		# try to expand left until fail
		var left_width = 1
		while true:
			var hit_edge = false
			for h in range(height):
				if not subarea.has_coordinate(start_pos + Vector2i(-left_width, h)): hit_edge = true
			if hit_edge: break
			left_width += 1
		
		var new_start_pos := Vector2i(start_pos.x - left_width + 1, start_pos.y)
		var new_rect := Rect2i(new_start_pos, Vector2i(right_width + left_width - 1, height))
		if new_rect.get_area() > largest_rect.get_area():
			largest_rect = new_rect
	
	return largest_rect
