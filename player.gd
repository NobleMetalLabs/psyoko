class_name Player
extends Node2D

@onready var attack_sprite : PlayerAttackSprite = $AttackSprite
var attacking : bool = false

signal moved(direction : Vector2i)
signal attacked(direction : Vector2i)

var accept_input : bool = true

func _process(_delta: float) -> void:
	if not accept_input:
		return
	if attacking:
		return

	var input_vector : Vector2 = Vector2.ZERO
	if Input.is_action_just_pressed("pl_up"):
		input_vector -= Vector2.UP
	elif Input.is_action_just_pressed("pl_down"):
		input_vector -= Vector2.DOWN
	else:
		if Input.is_action_just_pressed("pl_left"):
			input_vector += Vector2.LEFT
		elif Input.is_action_just_pressed("pl_right"):
			input_vector += Vector2.RIGHT
	
	if input_vector.length_squared() == 0:
		return

	if input_vector.x != 0:
		input_vector.y = 0

	var alternate : bool = Input.is_action_pressed("pl_alternate")

	if alternate:
		attacked.emit(input_vector)
	else:
		moved.emit(input_vector)
