class_name PlayerController extends Controller

@onready var action_box: HBoxContainer = %ActionBox
@onready var cycle_left_button: ActionButton = %CycleLeftButton
@onready var cycle_right_button: ActionButton = %CycleRightButton
@onready var beer_button: ActionButton = %BeerButton
@onready var swipe_button: ActionButton = %SwipeButton


# ENGINE
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and !ready_queue.is_empty():
		_end_turn()


# PUBLIC


# PRIVATE
func _update():
	if ready_queue.is_empty():
		_end_turn()
		return
	cycle_left_button.disabled = ready_queue.size() == 1
	cycle_right_button.disabled = ready_queue.size() == 1
	jump_to_active()


# SIGNALS
func _on_heist_turn_changed(new_turn: Heist.Turn) -> void:
	action_box.visible = new_turn == Heist.Turn.PLAYER
	if new_turn != Heist.Turn.PLAYER:
		_turn_ended()
		return
	print("my turn!")
	_start_turn()


func _on_cycle_button_pressed(next: bool) -> void:
	if ready_queue.size() <= 1:
		return
	if next:
		ready_queue.push_back(ready_queue.pop_front())
	else:
		ready_queue.push_front(ready_queue.pop_back())
	_update()

func _on_pass_button_pressed() -> void:
	ready_queue.pop_front()
	_update()
