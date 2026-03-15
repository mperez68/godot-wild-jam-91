@tool
class_name ActionButton extends SfxButton

enum Icon{ PASS, STEAL_BEER, SWIPE }
var icon_map: Dictionary[Icon, Vector2] = {
	Icon.PASS: Vector2.ZERO,
	Icon.STEAL_BEER: Vector2(16.0, 0.0),
	Icon.SWIPE: Vector2(32.0, 0.0)
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
