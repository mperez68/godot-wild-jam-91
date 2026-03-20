@tool
class_name Watcher extends Character

@export var vis_range: float = 4.0

var chase_target: Character


# ENGINE
func _ready():
	super()
	if !Engine.is_editor_hint():
		draw_vis()


# PUBLIC
func draw_vis():
	if chase_target:
		return
	var vis_tiles: Array[Vector2i]
	var map: Map = TacGrid.get_map()
	for x in range(grid_position.x - ceili(vis_range), grid_position.x + ceili(vis_range) + 1):
		for y in range(grid_position.y - ceili(vis_range), grid_position.y + ceili(vis_range) + 1):
			var temp_grid: Vector3i = Vector3i(x, y, grid_position.z)
			if can_see_cone(temp_grid) and grid_position != temp_grid and !map.get_cell_tile_data(temp_grid):
				vis_tiles.push_back(Vector2i(x, y))
	map.draw_vis_tiles(vis_tiles)

func can_see_cone(target: Vector3i) -> bool:
	return can_see(target, vis_range) and abs(angle_difference(arrow_sprite.rotation, Vector2(target.x - grid_position.x, target.y - grid_position.y).angle())) < PI / 4

func scan_targets():
	if chase_target:
		return
	for entity in get_tree().get_nodes_in_group("player"):
		if entity is Gnome and can_see_cone(entity.grid_position):
			MusicManager.play_leads(true)
			chase_target = entity
			chase_target.spotted_sprite_2d.show()
			aggro_sfx.play()
			aggro_sprite_2d.show()
			update_vis_ranges()
			return

func turn(dir: int = 0):
	super(dir)
	update_vis_ranges()
	scan_targets()

# PRIVATE


# SIGNALS
func _on_moved(start: Vector3i) -> void:
	super(start)
	update_vis_ranges()

func update_vis_ranges():
	TacGrid.get_map().clear_vis_tiles()
	for entity in get_tree().get_nodes_in_group("computer"):
		if entity is Watcher:
			entity.draw_vis()
