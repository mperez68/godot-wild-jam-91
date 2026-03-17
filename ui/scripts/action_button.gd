@tool
class_name ActionButton extends SfxButton

enum Icon{ PASS, STEAL_BEER, SWIPE, RIGHT, LEFT, UP, DOWN, TELEPORT, WARD, DUST, NONE, EXTRACT }
var icon_map: Dictionary[Icon, Vector2] = {
	Icon.PASS: Vector2.ZERO,
	Icon.STEAL_BEER: Vector2(16.0, 0.0),
	Icon.SWIPE: Vector2(32.0, 0.0),
	Icon.RIGHT: Vector2(0.0, 32.0),
	Icon.LEFT: Vector2(16.0, 32.0),
	Icon.UP: Vector2(32.0, 32.0),
	Icon.DOWN: Vector2(48.0, 32.0),
	Icon.TELEPORT: Vector2(32.0, 16.0),
	Icon.WARD: Vector2(0.0, 16.0),
	Icon.DUST: Vector2(16.0, 16.0),
	Icon.NONE: Vector2(48.0, 16.0),
	Icon.EXTRACT: Vector2(48.0, 0.0)
}

@export var icon_type: Icon = Icon.PASS:
	set(value):
		icon_type = value
		tooltip_text = str(Icon.keys()[icon_type]).capitalize()
		if icon != null:
			icon.region.position = icon_map[icon_type]


# ENGINE


# PUBLIC


# PRIVATE


# SIGNALS
