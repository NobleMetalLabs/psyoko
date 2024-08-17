#class_name UIDDB
extends Node

## God database for all synchronized objects and their unique ids.

var uid_to_object : Dictionary = {}
var object_to_uid : Dictionary = {}

func register_object(_object : Object, _uid : int) -> int:
	if object_to_uid.has(_object):
		push_error("Object %s already registered." % [_object])
		assert(false)
	if uid_to_object.has(_uid):
		push_error("Object with uid %s already registered." % [_uid])
		assert(false)

	uid_to_object[_uid] = _object
	object_to_uid[_object] = _uid

	# print("%s/UIDDB : Assigned object %s with uid %s." % [MultiplayerManager.get_peer_id(), _object, _uid])

	return _uid

func unregister_object(_object : Object) -> void:
	if object_to_uid.has(_object):
		uid_to_object.erase(object_to_uid[_object])
		object_to_uid.erase(_object)

func has_object(_object : Object) -> bool:
	return object_to_uid.has(_object)

func has_uid(_uid : int) -> bool:
	return uid_to_object.has(_uid)

func object(_uid : int) -> Object:
	if not uid_to_object.has(_uid):
		push_error("Object with uid %s not found." % [_uid])
		assert(false)
	return uid_to_object.get(_uid, null)

func uid(_object : Object) -> int:
	if not object_to_uid.has(_object):
		push_error("Object %s not registered." % [_object])
		assert(false)
	return object_to_uid.get(_object, -1)

func clear() -> void:
	uid_to_object.clear()
	object_to_uid.clear()
