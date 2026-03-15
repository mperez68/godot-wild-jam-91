class_name ComputerController extends Controller


# ENGINE


# PUBLIC


# PRIVATE
func _update():
	pass


# SIGNALS
func _on_heist_turn_changed(new_turn: Heist.Turn) -> void:
	if new_turn != Heist.Turn.COMPUTER:
		_turn_ended()
		return
	print("comp turn!") 
	_start_turn()
