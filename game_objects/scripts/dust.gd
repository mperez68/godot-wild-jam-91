@tool
class_name Dust extends GridNode2D

const STUN_MIN: int = 1
const STUN_MAX: int = 3

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D


# ENGINE
func _ready():
	for entity in get_tree().get_nodes_in_group("computer"):
		if entity is Character and entity.grid_position == grid_position:
			entity.stun(randi_range(STUN_MIN, STUN_MAX))


# PUBLIC


# PRIVATE


# SIGNALS
func _on_animated_sprite_2d_animation_finished() -> void:
	if !Engine.is_editor_hint():
		queue_free()
