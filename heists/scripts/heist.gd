class_name Heist extends Node2D

signal turn_changed(new_turn: Turn)

enum Turn{ NONE, PLAYER, COMPUTER }

@onready var map: Map = %Map
@onready var dropzone: TileMapLayer = %Dropzone
@onready var camera: BoundCamera = %BoundCamera
@onready var ui: PlayerController = %UI

@export var level_name: String = ""
@export var beer_quota: int = 1

var beers: int = 0
var trinkets: int = 0
var turn: Turn = Turn.NONE:
	set(value):
		if turn == value:
			return
		turn = value
		turn_changed.emit(turn)


# ENGINE
func _ready() -> void:
	MusicManager.play("level")
	MusicManager.play_leads(false)
	var limits: Rect2 = Rect2(map.used_rect)
	limits.position *= TacGrid.grid_size
	limits.size *= TacGrid.grid_size
	camera.set_limits(limits)
	start_game()


# PUBLIC
func start_game():
	var dropzone_tiles: Array[Vector3i]
	for x in range(map.used_rect.position.x, map.used_rect.position.x + map.used_rect.size.x):
		for y in range(map.used_rect.position.y, map.used_rect.position.y + map.used_rect.size.y):
			if dropzone.get_cell_tile_data(Vector2i(x, y)):
				dropzone_tiles.push_back(map.grid2d_to_grid3d(Vector2i(x, y), true))
	ui.dropzone = dropzone_tiles
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
	if !map.is_in_fog(map.local_to_grid3d(pos, true)):
		camera.position = pos

func _on_turn_changed(new_turn: Heist.Turn) -> void:
	camera.locked = new_turn != Turn.PLAYER

func _on_ui_extract(new_beers: int, new_trinkets: int) -> void:
	beers += new_beers
	trinkets += new_trinkets
