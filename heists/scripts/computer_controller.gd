class_name ComputerController extends Controller

@onready var pause_timer: Timer = %PauseTimer


# ENGINE


# PUBLIC


# PRIVATE
func _start_turn():
	super()
	pause_timer.start()

func _update():
	if locked_characters > 0:
		return
	if ready_queue.is_empty():
		_end_turn()
		return
	# Check actions left
	jump_to_active()
	var ready_character: Character = ready_queue.front()
	if ready_character.actions <= 0:
		_pop_ready()
		_start_timer_if_visible()
		return
	var map: Map = TacGrid.get_map()
	if ready_character is Watcher and ready_character.chase_target:
		if ready_character.can_see_target(ready_character.chase_target, 1, map):
			# Close enough to strike
			ready_character.chase_target.stun(1)
			ready_character.actions -= 1
			_start_timer_if_visible()
			return
		# Get route to approach
		var route: Array[Vector3i] = map.get_route_near(ready_character.grid_position, ready_character.chase_target.grid_position).slice(0, ready_character.speed)
		if route.is_empty():
			# No route, pass turn
			_pop_ready()
		else:
			# Approach target
			ready_character.move_to(route.back())
			return
	else:
		ready_character.do_behavior()
		_pop_ready()
	_start_timer_if_visible()

func _start_timer_if_visible():
	var map: Map = TacGrid.get_map()
	if !ready_queue.is_empty() and !map.is_in_fog(ready_queue.front().grid_position):
		pause_timer.start(1.0)
	else:
		pause_timer.start(0.01)
	


# SIGNALS
func _on_heist_turn_changed(new_turn: Heist.Turn) -> void:
	if new_turn != Heist.Turn.COMPUTER:
		_turn_ended()
		return
	print("comp turn!") 
	_start_turn()

func _on_pause_timer_timeout() -> void:
	_update()
