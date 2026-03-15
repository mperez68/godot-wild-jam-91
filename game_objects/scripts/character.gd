@tool
class_name Character extends GridNode2D

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var arrow_sprite: Sprite2D = %ArrowSprite

@export_placeholder("Character Name") var display_name: String = "":
	set(value):
		display_name = value
		_update_tooltip()
@export_placeholder("No Subtitle") var sub_name: String = "":
	set(value):
		sub_name = value
		_update_tooltip()


# ENGINE
func _ready():
	super()
	_update_face()


# PUBLIC
func start_turn():
	print("%s starts turn" % display_name)

func end_turn():
	print("%s ends turn" % display_name)


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
