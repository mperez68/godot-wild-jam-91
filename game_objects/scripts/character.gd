@tool
class_name Character extends GridNode2D

signal lock_changed(new_state: bool)

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var arrow_sprite: Sprite2D = %ArrowSprite
@onready var move_timer: Timer = %MoveTimer
@onready var spotted_sprite_2d: Sprite2D = %SpottedSprite2D
@onready var aggro_sprite_2d: Sprite2D = %AggroSprite2D

@onready var stun_sfx: AudioStreamPlayer2D = %StunSfx
@onready var move_sfx: AudioStreamPlayer2D = %MoveSfx
@onready var aggro_sfx: AudioStreamPlayer2D = %AggroSfx
@onready var trinket_sfx: AudioStreamPlayer2D = %TrinketSfx
@onready var beer_sfx: AudioStreamPlayer2D = %BeerSfx
@onready var ability_sfx: AudioStreamPlayer2D = %AbilitySfx

@export_placeholder("Character Name") var display_name: String = "":
	set(value):
		display_name = value
		_update_tooltip()
@export_placeholder("No Subtitle") var sub_name: String = "":
	set(value):
		sub_name = value
		_update_tooltip()
@export_range(0.0, 6.0, 1.0, "or_greater") var speed: int = 5
@export_range(0.0, 3.0, 1.0) var action_limit: int = 2

var actions: int = 0
var movement_queue: Array[Vector3i]:
	set(value):
		movement_queue = value
		if !movement_queue.is_empty():
			move_timer.start()
			locked = true
var locked: bool = false:
	set(value):
		if locked == value:
			return
		locked = value
		lock_changed.emit(locked)
var stunned_turns: int = 0


# ENGINE
func _ready():
	super()
	_update_face()


# PUBLIC
func start_turn():
	if stunned_turns > 0:
		stunned_turns -= 1
		stun_sfx.play()
		print("Stunned! %s" % display_name)
	else:
		animated_sprite_2d.play("idle")
		actions = action_limit

func end_turn():
	actions = 0

func can_travel(target: Vector3i) -> bool:
	return TacGrid.get_map().is_navigable(grid_position, target, speed)

func move_to(target: Vector3i) -> bool:
	if !can_travel(target) or actions <= 0:
		return false
	movement_queue = TacGrid.get_map().get_route(grid_position, target)
	actions -= 1
	move_sfx.play()
	return true

func turn(dir: int = 0):
	if dir == 0:
		dir = -1 if randf() > 0.5 else 1
	facing = ((dir + (facing as int)) % Facing.size()) as Facing
	move_sfx.play()

func stun(turns: int):
	stun_sfx.play()
	stunned_turns += turns
	animated_sprite_2d.play("die")

func get_display_name() -> String:
	var ret: String = "%s" % display_name
	if sub_name:
		ret += ", %s" % sub_name
	return ret


# PRIVATE
func _update_tooltip():
	pass

func _update_face():
	if animated_sprite_2d:
		if facing == Facing.LEFT:
			animated_sprite_2d.flip_h = true
		elif facing == Facing.RIGHT:
			animated_sprite_2d.flip_h = false
	if arrow_sprite:
		arrow_sprite.rotation = (PI / 2) * int(facing)


# SIGNALS
func _on_moved(_start: Vector3i) -> void:
	TacGrid.get_map().update_fog()
	for entity in get_tree().get_nodes_in_group("computer"):
		if entity is Watcher:
			entity.scan_targets()

func _on_move_timer_timeout() -> void:
	if movement_queue.is_empty():
		move_timer.stop()
		locked = false
		return
	face_and_move(movement_queue.pop_front())
