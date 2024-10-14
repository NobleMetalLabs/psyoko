#class_name MultiplayerManager
extends Node

var ADDRESS : String = "127.0.0.1"
const PORT = 31570

func send_network_message(message : String, args : Array, recipient_id : int = -1, remote_only : bool = false) -> void:
	var msg_obj := NetworkMessage.setup(get_peer_id(), message, args)
	var msg_dict : Dictionary = msg_obj.serialize()
	#print("%s : Sending message %s" % [get_peer_id(), msg_obj])
	#print("%s : Sending message %s" % [get_peer_id(), msg_dict])
	if recipient_id == -1:
		rpc("receive_network_message", var_to_bytes(msg_dict))
	else:
		rpc_id(recipient_id, "receive_network_message", var_to_bytes(msg_dict))
	if remote_only: return
	received_network_message.emit(msg_obj.sender_peer_id, message, args)

signal received_network_message(sender_id : int, message : String, args : Array)
@rpc("any_peer", "reliable")
func receive_network_message(bytes : PackedByteArray) -> void:
	var msg_dict : Dictionary = bytes_to_var(bytes)
	#print("\n%s : Handling message \n%s\n" % [get_peer_id(), JSON.stringify(msg_dict, "\t")])
	var message : NetworkMessage = Serializeable.deserialize(msg_dict)
	#print("%s : Handling message %s" % [get_peer_id(), message])
	received_network_message.emit(message.sender_peer_id, message.message, message.args)

var multiplayer_peer := ENetMultiplayerPeer.new()
var peer_ids : Array[int] = []

var connected : bool = false

var upnp : UPNP = UPNP.new()
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if upnp.get_device_count() > 0:
			upnp.delete_port_mapping(PORT, "UDP")

signal hosted_lobby()
func host_lobby(over_lan : bool = false) -> void:
	if not over_lan:
		upnp_discovery_thread.start(conduct_upnp_discovery)
	else:
		_create_server()

func _create_server() -> void:
	multiplayer_peer.create_server(PORT)
	multiplayer.multiplayer_peer = multiplayer_peer
	connected = true
	print("Server started on port %s with clientid %s" % [PORT, get_peer_id()])
	peer_ids.append(get_peer_id())
	player_connected.emit(get_peer_id())

	Router.game.world.initialize_world()
	hosted_lobby.emit()

func _process(_delta : float) -> void:
	upnp_discovery_thread_checkup()

var upnp_discovery_thread : Thread = Thread.new() 
func conduct_upnp_discovery() -> void:
	var discover_result := upnp.discover() as UPNP.UPNPResult
	if discover_result == UPNP.UPNP_RESULT_SUCCESS:
		if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
			var result_udp := upnp.add_port_mapping(PORT, PORT, "Psyoko Multiplayer", "UDP")
			if not result_udp == UPNP.UPNP_RESULT_SUCCESS:
				upnp.add_port_mapping(PORT, PORT, "", "UDP")
		ADDRESS = upnp.query_external_address()

func upnp_discovery_thread_checkup() -> void:
	if not upnp_discovery_thread.is_started(): return
	if upnp_discovery_thread.is_alive(): return
	upnp_discovery_thread.wait_to_finish()
	_create_server()

signal joined_lobby()
func join_lobby() -> void:
	multiplayer_peer.create_client(ADDRESS, PORT)
	multiplayer.multiplayer_peer = multiplayer_peer
	connected = true
	print("Joined server with clientid %s" % [get_peer_id()])
	peer_ids.append(get_peer_id())
	player_connected.emit(get_peer_id())
	joined_lobby.emit()

func exit_lobby() -> void:
	multiplayer_peer = ENetMultiplayerPeer.new()
	multiplayer.multiplayer_peer = null
	print("Left server")

func is_in_server() -> bool:
	return connected

func is_instance_server() -> bool:
	if not is_in_server(): return false
	return get_peer_id() == 1

func get_peer_id() -> int:
	if multiplayer == null: return -1
	return multiplayer.get_unique_id()

func get_local_player() -> Node:
	var my_id : int = get_peer_id()
	if UIDDB.has_uid(my_id):
		return UIDDB.object(my_id)
	return null

func get_num_players() -> int:
	return peer_ids.size()

func _ready() -> void:
	multiplayer.peer_connected.connect(on_player_connected)
	multiplayer.peer_disconnected.connect(on_player_disconnected)

func on_player_connected(peer_id : int) -> void:
	peer_ids.append(peer_id)
	player_connected.emit(peer_id)
	
	if is_instance_server():
		send_network_message("game/state_init", [Aligner.get_time(), WorldData.biome_zoner.biome_noise.seed], peer_id, true)
	
signal player_connected(peer_id : int)

func on_player_disconnected(peer_id : int) -> void:
	if peer_id == 1:
		exit_lobby.call_deferred()
		print("Host disconnected.")
		return
	peer_ids.erase(peer_id)
