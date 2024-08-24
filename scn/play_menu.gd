class_name PlayMenu
extends Control

@onready var name_line_edit : LineEdit = self.find_child("NameLineEdit", true, false)
@onready var play_button : Button = self.find_child("PlayButton", true, false)

signal play_requested(player_name : String)

func _ready() -> void:
	play_button.pressed.connect(
		func play_game() -> void:

			play_requested.emit(name_line_edit.text)
	)
