#class_name Aligner
extends Node

var event_list : Array[Event] = []

var time_start : int = 0
func reset_time() -> void:
	time_start = Time.get_ticks_msec()

func get_time() -> int:
	return Time.get_ticks_msec() - time_start

func _ready():
	MultiplayerManager.received_network_message.connect(
		func handle_network_message(_sender_id : int, message : String, args : Array) -> void:
		if message == "event":
			_handle_event(args[0])
		if message == "time/reset":
			reset_time()
	)

func submit_event(new_event : Event) -> void:
	MultiplayerManager.send_network_message("event", [new_event])

func _handle_event(new_event : Event) -> void:
	var event_time : int = new_event.time
	var events_to_undo : Array[Event] = []
	for i in range(event_list.size() - 1, -1, -1):
		var current_event : Event = event_list[i]
		if current_event.time < event_time:
			break
		events_to_undo.append(current_event)

	for event in events_to_undo:
		event.undo()
		event_list.erase(event)
	
	new_event.do()
	event_list.append(new_event)

	events_to_undo.reverse()
	for event in events_to_undo:
		event.do()
		event_list.append(event)
