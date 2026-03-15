class_name ComputerController extends Controller

@onready var pause_timer: Timer = %PauseTimer


# ENGINE


# PUBLIC


# PRIVATE
func _update():
	pause_timer.start()


# SIGNALS
func _on_heist_turn_changed(new_turn: Heist.Turn) -> void:
	if new_turn != Heist.Turn.COMPUTER:
		_turn_ended()
		return
	print("comp turn!") 
	_start_turn()

func _on_pause_timer_timeout() -> void:
	_end_turn()	# TODO actual turn
