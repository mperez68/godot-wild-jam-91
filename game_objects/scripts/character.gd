@tool
class_name Character extends GridNode2D

@onready var arrow_sprite: Sprite2D = %ArrowSprite


# ENGINE
func _ready():
	super()
	_update_face()


# PUBLIC


# PRIVATE
func _update_face():
	if arrow_sprite:
		arrow_sprite.rotation = (PI / 2) * int(facing)


# SIGNALS
func _on_moved(_start: Vector3i) -> void:
	TacGrid.get_map().update_fog()
