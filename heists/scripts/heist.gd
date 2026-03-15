class_name Heist extends Node2D

signal turn_changed(new_turn: Turn)

enum Turn{ NONE, PLAYER, COMPUTER }

@onready var map: Map = %Map

@export var turn: Turn = Turn.NONE:
	set(value):
		if turn == value:
			return
		turn = value
		turn_changed.emit(turn)


# ENGINE
func _ready() -> void:
	start_game()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		pass_turn()


# PUBLIC
func start_game():
	turn = Turn.PLAYER

func pass_turn():
	match turn:
		Turn.NONE:
			printerr("Game not started!")
		Turn.PLAYER:
			turn = Turn.COMPUTER
		Turn.COMPUTER:
			turn = Turn.PLAYER

func end_game():
	turn = Turn.NONE


# PRIVATE


# SIGNALS
