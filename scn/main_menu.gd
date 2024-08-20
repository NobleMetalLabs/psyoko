class_name MainMenu
extends Control

@onready var name_line_edit : LineEdit = self.find_child("NameLineEdit", true, false)
@onready var private_server_checkbox : CheckBox = self.find_child("PrivateServerCheckBox", true, false)
@onready var server_ip_stack : Container = self.find_child("ServerIPStack", true, false)
@onready var server_ip_line_edit : LineEdit = self.find_child("ServerIPLineEdit", true, false)
@onready var play_button : Button = self.find_child("PlayButton", true, false)

signal play_requested(player_name : String, private_server : bool, server_ip : String)

func _ready() -> void:
	private_server_checkbox.toggled.connect(
		func show_server_options(yes : bool) -> void:
			server_ip_stack.visible = yes
	)

	play_button.pressed.connect(
		func play_game() -> void:
			var player_name : String = name_line_edit.text
			var private_server : bool = private_server_checkbox.button_pressed
			var server_ip : String = server_ip_line_edit.text
			play_requested.emit(player_name, private_server, server_ip)
	)
