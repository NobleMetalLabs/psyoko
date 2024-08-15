class_name PlayerAttackSprite
extends AnimatedSprite2D

@onready var player : Player = get_parent()

func _ready() -> void:
	self.animation_finished.connect(func() -> void:
		self.play("default")
		player.attacking = false
	)

func attack(direction : Vector2i, is_long : bool) -> void:
	self.rotation = Vector2(direction).angle_to(Vector2i.RIGHT)
	player.attacking = true
	self.play("attack")
	
	if not is_long: self.scale = Vector2(2.5, 2.5)
	else: self.scale = Vector2(5, 1)

func cancel() -> void:
	self.stop()
	self.play("default")

func ff(time_seconds : float) -> void:
	self.frame = int(time_seconds * self.sprite_frames.get_animation_speed("attack"))

func _process(_delta) -> void:
	var current_animation : String = self.animation
	var frame_count : int = self.sprite_frames.get_frame_count(current_animation)
	var current_frame : int = self.frame
	var progress : float = float(current_frame) / frame_count

	self.self_modulate.a = 1.0 - progress
