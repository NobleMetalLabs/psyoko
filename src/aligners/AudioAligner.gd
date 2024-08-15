class_name AudioAligner
extends Node

func _ready():
	Aligner.do_event.connect(do_event)
	Aligner.undo_event.connect(undo_event)
	Aligner.fast_forward_event.connect(fast_forward_event)

var event_to_audio_player : Dictionary = {}

func do_event(event : Event) -> void:
	var audio_stream : AudioStream = null
	if event is PlayerMoveEvent:
		audio_stream = load("res://ast/sound/game/move.wav")
	#elif event is PlayerSpawnEvent:
		#_do_spawn(event as PlayerSpawnEvent)
	elif event is PlayerAttackEvent:
		if event.is_long:
			audio_stream = load("res://ast/sound/game/attack_long.wav")
		else:
			audio_stream = load("res://ast/sound/game/attack.wav")
	elif event is PlayerDeathEvent:
		audio_stream = load("res://ast/sound/game/death.wav")
	
	if audio_stream != null:
		var new_audio_player := AudioStreamPlayer2D.new()
		var player : Player = MultiplayerManager.peer_id_to_player[event.player_id]

		if player == null:
			return
		
		player.add_child(new_audio_player, true)
		new_audio_player.stream = audio_stream
		new_audio_player.max_distance = Psyoko.MAX_TARGET_DISTANCE * Psyoko.SCREEN_SCALE * 1.25
		new_audio_player.play()
		
		new_audio_player.finished.connect(
			func audio_player_finished():
				new_audio_player.queue_free()
				event_to_audio_player.erase(event)
		)
		
		event_to_audio_player[event] = new_audio_player

func undo_event(event : Event) -> void:
	if event_to_audio_player.has(event):
		event_to_audio_player[event].queue_free()
		event_to_audio_player.erase(event)

func fast_forward_event(event : Event, time_seconds : float) -> void:
	if event_to_audio_player.has(event):
		event_to_audio_player[event].seek(time_seconds)
