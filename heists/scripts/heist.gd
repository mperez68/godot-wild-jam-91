class_name Heist extends Node2D

signal turn_changed(new_turn: Turn)

enum Turn{ NONE, PLAYER, COMPUTER }

@onready var map: Map = %Map
@onready var camera: BoundCamera = %BoundCamera


@export var turn: Turn = Turn.NONE:
	set(value):
		if turn == value:
			return
		turn = value
		turn_changed.emit(turn)


# ENGINE
func _ready() -> void:
	var limits: Rect2 = Rect2(map.used_rect)
	limits.position *= TacGrid.grid_size
	limits.size *= TacGrid.grid_size
	camera.set_limits(limits)
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
func _on_request_camera_position(pos: Vector2) -> void:
	camera.position = pos

func _on_turn_changed(new_turn: Heist.Turn) -> void:
	camera.locked = new_turn != Turn.PLAYER
		
