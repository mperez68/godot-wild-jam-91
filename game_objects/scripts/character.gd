@tool
class_name Character extends GridNode2D

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var arrow_sprite: Sprite2D = %ArrowSprite


# ENGINE
func _ready():
	super()
	_update_face()


# PUBLIC


# PRIVATE
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
