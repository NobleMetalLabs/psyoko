#class_name Aligner
extends Node

var event_list : Array[Event] = []

var start_time : int = Time.get_ticks_msec()

func set_start_time(time : int) -> void:
	start_time = time

func get_time() -> int:
	return Time.get_ticks_msec() + start_time

func _ready():
	self.add_child(ObjectAligner.new())
	self.add_child(PlayerAligner.new())
	self.add_child(AudioAligner.new())

	MultiplayerManager.received_network_message.connect(
		func handle_network_message(_sender_id : int, message : String, args : Array) -> void:
		if message == "event":
			_handle_event(args[0])
		if message == "game/state_init":
			set_start_time(args[0])
	)

func submit_event(new_event : Event) -> void:
	MultiplayerManager.send_network_message("event", [new_event])

signal do_event(event : Event)
signal undo_event(event : Event)
signal fast_forward_event(event : Event, time_seconds : float)

func _handle_event(new_event : Event) -> void:
	var event_time : int = new_event.time
	var events_to_undo : Array[Event] = []
	for i in range(event_list.size() - 1, -1, -1):
		var current_event : Event = event_list[i]
		if current_event.time < event_time:
			break
		events_to_undo.append(current_event)

	for event in events_to_undo:
		undo_event.emit(event)
		event_list.erase(event)
	
	do_event.emit(new_event)
	event_list.append(new_event)

	events_to_undo.reverse()
	for event in events_to_undo:
		do_event.emit(event)
		event_list.append(event)

	var last_event : Event = event_list.back()
	fast_forward_event.emit(last_event, (get_time() - last_event.time) / 1000.0)
