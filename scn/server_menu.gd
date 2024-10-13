class_name ServerMenu
extends Control

@onready var server_ip_line_edit : LineEdit = self.find_child("ServerIPLineEdit", true, false)
@onready var join_button : Button = self.find_child("JoinButton", true, false)
@onready var host_button : Button = self.find_child("HostButton", true, false)

signal join_requested(ip : String)
signal host_requested()

func _ready() -> void:
	server_ip_line_edit.text = MultiplayerManager.ADDRESS

	join_button.pressed.connect(
		func join_game() -> void:
			var ip : String = server_ip_line_edit.text
			begin_animating(ip)
			join_requested.emit(ip)
	)

	host_button.pressed.connect(host_requested.emit)

var animate : bool = false
var saved_ip : String 
func begin_animating(ip : String) -> void:
	animate = true
	saved_ip = ip

func stop_animating() -> void:
	animate = false

var stopw : float = 0
var char_idx : int = 0
func _process(delta):
	if not animate: return

	stopw += delta
	if stopw > 0.25:
		stopw = 0
		server_ip_line_edit.text = "%s-%s" % [saved_ip.left(char_idx), saved_ip.right(-char_idx - 1)] 
		char_idx += 1
		if char_idx >= saved_ip.length():
			char_idx = 0
		if saved_ip[char_idx] == ".":
			char_idx += 1
	