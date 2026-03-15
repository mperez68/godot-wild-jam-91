@abstract
class_name Controller extends Node

signal end_turn
signal request_camera_position(pos: Vector2)

@export var group_key: StringName

var ready_queue: Array[Character]


# ENGINE


# PUBLIC


# PRIVATE
func jump_to_active():
	if ready_queue.is_empty():
		return
	request_camera_position.emit(ready_queue.front().position)

@abstract
## Needs to move turn forward every time it is called. Check for dead ends that do not progress turn.
func _update()

func _start_turn():
	for node in get_tree().get_nodes_in_group(group_key):
		if node is Character:
			node.start_turn()
			ready_queue.push_back(node)
	_update()

func _end_turn():
	end_turn.emit()

func _turn_ended():
	for character in ready_queue:
		character.end_turn()
	ready_queue.clear()


# SIGNALS
