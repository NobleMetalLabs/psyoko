extends Node

@onready var pmove : AudioStreamPlayer = $"PMove"
@onready var pattack : AudioStreamPlayer = $"PAttack"
@onready var plattack : AudioStreamPlayer = $"PLAttack"
@onready var ambient : AudioStreamPlayer = $"Ambient"

var fade_in_tween : Tween = null
var fade_out_tween : Tween = null
var faded_in : bool = false

func fade_in() -> void:
	fade_in_tween = get_tree().create_tween()
	if fade_out_tween != null: fade_out_tween.kill()
	fade_in_tween.tween_method(set_volume, 0.0, 1.0, 2)
	faded_in = true

func fade_out() -> void:
	if not faded_in: return
	fade_out_tween = get_tree().create_tween()
	if fade_in_tween != null: fade_in_tween.kill()
	fade_out_tween.tween_method(set_volume, 1.0, 0.0, 1)
	faded_in = false

func set_volume(percent : float) -> void:
	pmove.volume_db = linear_to_db(percent)
	pattack.volume_db = linear_to_db(percent)
	plattack.volume_db = linear_to_db(percent)
	ambient.volume_db = linear_to_db(percent)

func _ready() -> void:
	ambient.play()
	ambient.finished.connect(ambient.play)

func _process(_delta: float) -> void:
	if randi_range(0, 10) == 0:
		if pmove.playing == false:
			pmove.play()

	if randi_range(0, 250) == 0:
		if pattack.playing == false:
			pattack.play()

	if randi_range(0, 500) == 0:
		if plattack.playing == false:
			plattack.play()
