class_name Player
extends Pushable

var username : String
@onready var attack_sprite : PlayerAttackSprite = $AttackSprite
@onready var audio_listener : AudioListener2D = $AudioListener2D
@onready var death_timer : Timer = $DeathTimer
@onready var collision_shape : CollisionShape2D = $CollisionShape2D

var attacking : bool = false
@onready var attack_base : Node2D = $"%AttackBase"
@onready var normal_attack_holder : Node2D = $"%NormalAttackCasts"
@onready var long_attack_cast : RayCast2D = $"%LongAttackCast"
var played_charge_sound : bool = false

signal moved(direction : Vector2i)
signal attacked(direction : Vector2i, long : bool)

var accept_input : bool = false
var attack_charge_value : float = 0
var number_of_kills : int = 0
var is_alive : bool = true

var chunk_coord : Vector2i
signal passed_chunk_border(coord : Vector2i)

func _process(delta: float) -> void:
	if not accept_input:
		return
	if attacking:
		return

	var input_vector : Vector2 = Vector2.ZERO
	if Input.is_action_just_pressed("pl_up"):
		input_vector -= Vector2.UP
	if Input.is_action_just_pressed("pl_down"):
		input_vector -= Vector2.DOWN
	if Input.is_action_just_pressed("pl_left"):
		input_vector += Vector2.LEFT
	if Input.is_action_just_pressed("pl_right"):
		input_vector += Vector2.RIGHT

	var alternate : bool = Input.is_action_pressed("pl_attack")
	if alternate:
		attack_charge_value += delta
		if attack_charge_value >= 1 and not played_charge_sound: 
			played_charge_sound = true
			$ChargedAudio.play()
	else:
		attack_charge_value = 0
		played_charge_sound = false
	
	if input_vector.is_zero_approx():
		return

	if input_vector.x != 0:
		input_vector.y = 0


	if alternate:
		var is_long : bool = (attack_charge_value >= 1) # probably make this a const lol
		attack_charge_value = 0
		played_charge_sound = false
		
		attacked.emit(input_vector, is_long)
		
	else:
		moved.emit(input_vector)
	
		var border_coord_check : Vector2i = WorldData.tile_to_chunk_coords(position / Psyoko.TILE_SIZE)
		if chunk_coord == border_coord_check: return
		
		chunk_coord = border_coord_check
		passed_chunk_border.emit(chunk_coord)
		print(chunk_coord)
