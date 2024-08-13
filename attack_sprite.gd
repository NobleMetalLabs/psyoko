extends AnimatedSprite2D

@onready var player : Player = get_parent()

func _ready() -> void:
	player.attacked.connect(show_attack)
	self.animation_finished.connect(func() -> void:
		self.play("default")
		player.attacking = false
		player.finished_attacking.emit()
	)

func _process(delta):
	var current_animation : String = self.animation
	var frame_count : int = self.sprite_frames.get_frame_count(current_animation)
	var current_frame : int = self.frame
	var progress : float = float(current_frame) / frame_count

	self.self_modulate.a = 1.0 - progress

func show_attack(direction : Vector2i) -> void:
	self.rotation = Vector2(direction).angle_to(Vector2i.RIGHT)

	if player.attacking:
		play("attack")
	else:
		play("default")
