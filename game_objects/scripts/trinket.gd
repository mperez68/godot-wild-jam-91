@tool
class_name Trinket extends GridNode2D

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D

@export var stolen: bool = false:
	set(value):
		stolen = value
		if animated_sprite_2d:
			if stolen:
				animated_sprite_2d.play("missing")
			else:
				animated_sprite_2d.play("idle")

# ENGINE


# PUBLIC
func steal():
	stolen = true

# PRIVATE


# SIGNALS
