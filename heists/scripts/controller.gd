@abstract
class_name Controller extends Node

signal end_turn
signal request_camera_position(pos: Vector2)

@export var group_key: StringName

var ready_queue: Array[Character]
var locked_characters: int = 0

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
			node.lock_changed.connect(_on_character_lock_changed)
			ready_queue.push_back(node)
	jump_to_active()
	_update()

func _end_turn():
	end_turn.emit()

func _turn_ended():
	while(_pop_ready()):
		pass
	ready_queue.clear()

func _pop_ready() -> Character:
	if ready_queue.is_empty():
		return null
	var ready_character: Character = ready_queue.pop_front()
	ready_character.lock_changed.disconnect(_on_character_lock_changed)
	ready_character.end_turn()
	return ready_character


# SIGNALS
func _on_character_lock_changed(new_state: bool):
	locked_characters += 1 if new_state else -1
	_update()
