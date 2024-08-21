class_name StructureZoner
extends Zoner

func zone(chunk : Chunk) -> void:
	var new_subareas : Array[Area]
	var existing_subareas : Array[Area] = []
	
	for area : Area in chunk.areas:
		var area_existing_subareas : Array[Area] = area.get_subareas()
		if area_existing_subareas.size() > 0: 
			existing_subareas.append_array(area_existing_subareas)
			continue

		var num_structures_in_area = round(area.get_coordinates().size() / 1000.0) + 1
		var unaccounted_tiles : Array[Vector2i] = area.get_coordinates().duplicate()
		var unexpanded_tiles_in_subarea : Dictionary = {}
		
		for i in range(num_structures_in_area):
			var subarea := Area.new()
			new_subareas.append(subarea)
			area.add_subarea(subarea)
			subarea.parent_area = area
			
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
	
	var new_structures : Array[Structure] = []
	for subarea : Area in new_subareas:
		var largest_rect : Rect2i = _largest_rect_in_subarea(subarea)
		var new_struct := Structure.new(largest_rect, randi_range(0, 10), subarea)
		new_structures.append(new_struct)
		subarea.add_structure(new_struct)

	print("%s new subareas in chunk %s" % [new_subareas.size(), chunk.world_coordinates])
	print("%s new structures in chunk %s" % [new_structures.size(), chunk.world_coordinates])

	chunk.structures += new_structures
	chunk.subareas += new_subareas
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
