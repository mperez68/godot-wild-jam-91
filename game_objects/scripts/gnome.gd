@tool
class_name Gnome extends Character

const WARD: PackedScene = preload("res://game_objects/ward.tscn")

enum Role{ MOOK, SNEAK, SPOTTER, DUSTER }

@export var role: Role = Role.MOOK:
	set(value):
		role = value
		sub_name = str(Role.keys()[role]).capitalize()

var beers_stolen: int = 0
var trinkets_stolen: int = 0
var teleport_queued: bool = false


# ENGINE


# PUBLIC
func move_to(target: Vector3i) -> bool:
	if !can_travel(target) or actions <= 0:
		return false
	if teleport_queued:
		teleport_queued = false
		face_and_move(target)
		actions -= 1
		return true
	return super(target)

func cast_special() -> bool:
	if actions <= 0:
		return false
	match role:
		Role.MOOK:
			printerr("Mooks don't have special abilities! Why was this pressable?")
			return false	# No special
		Role.SNEAK:
			teleport_queued = true
		Role.SPOTTER:
			var ward: GridNode2D = WARD.instantiate()
			ward.grid_position = grid_position
			add_sibling(ward)
		Role.DUSTER:
			print("Duster")		# TODO stun everyone within 3 tiles for 1d3 turns.
	actions -= 1
	return true


# PRIVATE


# SIGNALS
