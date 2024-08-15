extends Camera2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var input_vector : Vector2 = Vector2(
		Input.get_axis("pl_left", "pl_right"),
		Input.get_axis("pl_up", "pl_down"),
	)

	if Input.is_action_pressed("pl_alternate"):
		input_vector *= 5

	self.position += input_vector * 2 * Psyoko.TILE_SIZE * Psyoko.CHUNK_SIZE * delta