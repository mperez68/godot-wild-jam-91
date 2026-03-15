class_name PlayerController extends Controller


# ENGINE


# PUBLIC


# PRIVATE
func _update():
	pass


# SIGNALS
func _on_heist_turn_changed(new_turn: Heist.Turn) -> void:
	if new_turn != Heist.Turn.PLAYER:
		_turn_ended()
		return
	print("my turn!")
	_start_turn()
