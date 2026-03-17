@tool
class_name Gnome extends Character

const WARD: PackedScene = preload("res://game_objects/ward.tscn")
const DUST: PackedScene = preload("res://game_objects/dust.tscn")

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
			spawn_dusts()
	actions -= 1
	return true


# PRIVATE
func spawn_dusts(radius: float = 3):
	for x in range(grid_position.x - ceili(radius), grid_position.x + ceili(radius) + 1):
		for y in range(grid_position.y - ceili(radius), grid_position.y + ceili(radius) + 1):
			var grid_temp = TacGrid.get_map().grid2d_to_grid3d(Vector2i(x, y), true)
			if can_see(grid_temp, radius):
				var dust: Dust = DUST.instantiate()
				dust.grid_position = grid_temp
				add_sibling(dust)


# SIGNALS
