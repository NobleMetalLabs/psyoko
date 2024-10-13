class_name PlayMenu
extends Control

@onready var name_line_edit : LineEdit = self.find_child("NameLineEdit", true, false)
@onready var color_picker_button : Button = self.find_child("ColorPickerButton", true, false)
@onready var settings_button : Button = self.find_child("SettingsButton", true, false)
@onready var play_button : Button = self.find_child("PlayButton", true, false)
@onready var change_server_button : Button = self.find_child("ChangeServerButton", true, false)

signal play_requested(player_name : String, player_color : Color)
signal settings_requested()
signal change_server_requested()

func _ready() -> void:
	play_button.pressed.connect(
		func play_game() -> void:
			play_requested.emit(name_line_edit.text, color_picker_button.color)
	)
	settings_button.pressed.connect(settings_requested.emit)
	change_server_button.pressed.connect(change_server_requested.emit)

func show_menu() -> void:
	var is_in_server : bool = MultiplayerManager.is_in_server()
	play_button.disabled = not is_in_server
	color_picker_button.disabled = not is_in_server
	name_line_edit.editable = is_in_server
	self.show()
