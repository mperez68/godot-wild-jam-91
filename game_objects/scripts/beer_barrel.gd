@tool
class_name BeerBarrel extends GridNode2D

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D

@export var expended: bool = false:
	set(value):
		expended = value
		if animated_sprite_2d:
			animated_sprite_2d.animation = "sabotaged" if expended else "default"


# ENGINE
func _ready():
	super()
	expended = expended


# PUBLIC


# PRIVATE


# SIGNALS
