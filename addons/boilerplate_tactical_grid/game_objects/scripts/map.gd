class_name Map extends Node2D

## Emitted when the map has been read in and the navigation map is fully built.
signal initialized

enum Highlight{ MOVE_HIGHLIGHT, MOVE_HOVER, TARGET_HIGHLIGHT, TARGET_HOVER }

const MAX_COORDINATE_SIZE: int = 3
const CLIMB_KEY: String = "climb_weight"
const INTERVENING_DEPTH: int = 2	# 0 is starting position, 1 is adjacent tiles, so 2 is where intervening begins.

## The movement cost to climb walls. If less than 0, walls cannot be climbed unless the tile has a custom data value "climb_weight" set as a float.
@export_range(-1.0, 5.0, 0.1, "or_greater") var climb_weight: float = -1
@export var use_fog: bool = true

@onready var util_layers: Array[TileMapLayer] = [%FogOfWar, %HighlightLayer, %AttackLayer, %HoverLayer  ]
@onready var fog_of_war: TileMapLayer = %FogOfWar
@onready var target_layer: TileMapLayer = %TargetLayer
@onready var highlight_layer: TileMapLayer = %HighlightLayer
@onready var hover_layer: TileMapLayer = %HoverLayer

var layers: Array[TileMapLayer]
var nav: AStar3D
var used_rect: Rect2i
var is_initialized: bool = false


# ENGINE
func _ready():
	initialize()

func initialize():
	var beginning: Vector2 = Vector2.INF
	var end: Vector2 = Vector2.ZERO
	## Populate Layers
	for layer in get_children():
		if layer is TileMapLayer and !util_layers.has(layer):
			layers.push_back(layer)
			var rect: Rect2i = layer.get_used_rect()
			beginning.x = min(beginning.x, rect.position.x)
			beginning.y = min(beginning.y, rect.position.y)
			end.x = max(end.x, rect.size.x + rect.position.x)
			end.y = max(end.y, rect.size.y + rect.position.y)
	used_rect = Rect2i(beginning, end - beginning)
	# Buffer layer for navigation
	layers.push_back(TileMapLayer.new())
	# Populate Navigation
	nav = AStar3D.new()
	var fog_coverage: Array[Vector2i]
	for index in layers.size():
		for x in used_rect.size.x + 1:
			for y in used_rect.size.y + 1:
				var pos: Vector3i = Vector3i(x, y, index)
				if can_stand(pos):
					_add_point(pos)
				var pos_2d: Vector2i = Vector2i(x, y)
				if !fog_coverage.has(pos_2d):
					fog_coverage.push_back(pos_2d)
	if use_fog:
		fog_of_war.set_cells_terrain_connect(fog_coverage, 0, 0)
	is_initialized = true
	initialized.emit()


# PUBLIC
# Tightening getters
## Returns the given position that local to the map as the 2d grid position as it fits in the map.
func local_to_grid2d(local_position: Vector2) -> Vector2i:
	return Vector2i(floori(local_position.x / float(TacGrid.grid_size.x)), floori(local_position.y / float(TacGrid.grid_size.y)))

## Returns the given 2d grid position as the visible 3d grid position on the map.
func grid2d_to_grid3d(grid_position: Vector2i, open_space: bool = false) -> Vector3i:
	for i in range(layers.size() - 1, -1, -1):
		if layers[i].get_cell_tile_data(grid_position):
			return Vector3i(grid_position.x, grid_position.y, i) + Vector3i.BACK if open_space else Vector3i.ZERO
	return Vector3i.ZERO

## returns the 3d grid position on the highest level of the given map of the given local position.
func local_to_grid3d(local_position: Vector2, open_space: bool = false) -> Vector3i:
	return grid2d_to_grid3d(local_to_grid2d(local_position), open_space)

# Loosening getters
## Flattens a given 3d grid position to a 2d grid position.
func grid3d_to_grid2d(grid_position: Vector3i) -> Vector2i:
	return Vector2i(grid_position.x, grid_position.y)

## Returns the local position of a given 2d grid position.
func grid2d_to_local(grid_position: Vector2i) -> Vector2:
	return (Vector2(grid_position) * TacGrid.grid_size) + (TacGrid.grid_size / 2)

## Flattens and returns the local position of a given 3d grid position.
func grid3d_to_local(grid_position: Vector3i) -> Vector2:
	return grid2d_to_local(grid3d_to_grid2d(grid_position))

# cell data getters
## Returns the TileData object associated with the given cell, or null if the cell does not exist or is not a TileSetAtlasSource.
func get_cell_tile_data(coords: Vector3i) -> TileData:
	return layers[coords.z].get_cell_tile_data(Vector2i(coords.x, coords.y))

## Returns the TileData object associated with the cell at the highest z-axis of the given coordinates, or null if the cell does not exist or is not a TileSetAtlasSource.
func get_cell_tile_data_2d(coords: Vector2i) -> TileData:
	return layers[grid2d_to_grid3d(coords).z].get_cell_tile_data(Vector2i(coords.x, coords.y))

## Returns the TileData object associated with the cell at the given local position, or null if the cell does not exist or is not a TileSetAtlasSource.
func get_cell_tile_data_local(local_position: Vector2) -> TileData:
	var coords: Vector3i = local_to_grid3d(local_position)
	return layers[coords.z].get_cell_tile_data(Vector2i(coords.x, coords.y))

## Disables or enables the specified point for pathfinding. Useful for making a temporary obstacle.
func set_point_disabled(pos: Vector3i, solid: bool = true):
	nav.set_point_disabled(_grid3d_to_id(pos), solid)

# Navigation
## Returns an array with the points that are in the path found by AStar3D between the given points. The array is ordered from the starting point to the ending point of the path.
## start_inclusive will include the start point of the route. # end_inclusive will include the final point in the route.
## If there is no valid path to the target, and allow_partial_path is true, returns a path to the point closest to the target that can be reached.
## Note: This method is not thread-safe; it can only be used from a single Thread at a given time. Consider using Mutex to ensure exclusive access to one thread to avoid race conditions.
func get_route(start: Vector3i, end: Vector3i, start_inclusive: bool = false, end_inclusive: bool = true) -> Array[Vector3i]:	# TODO include tolerance to find nearest point within a given radius.
	var start_id := _grid3d_to_id(start)
	var end_id := _grid3d_to_id(end)
	if !nav.has_point(start_id) or !nav.has_point(end_id):
		return []
	var starting_disabled: bool = nav.is_point_disabled(start_id)
	nav.set_point_disabled(start_id, false)
	var path := nav.get_point_path(start_id, end_id)
	nav.set_point_disabled(start_id, starting_disabled)
	var route_3d: Array[Vector3i] = []
	for point in path:
		route_3d.push_back(Vector3i(point))
	if !start_inclusive:
		route_3d.pop_front()
	if !end_inclusive:
		route_3d.pop_back()
	return route_3d

func get_route_near(start: Vector3i, end: Vector3i, range_tolerance: float, require_visibility: bool) -> Array[Vector3i]:
	var best_route: Array[Vector3i] = []
	for x in range(end.x - ceili(range_tolerance), end.x + ceili(range_tolerance) + 1):
		for y in range(end.y - ceili(range_tolerance), end.y + ceili(range_tolerance) + 1):
			var offset: Vector3i = grid2d_to_grid3d(Vector2i(x, y), true)
			var temp_route: Array[Vector3i] = get_route(start, offset)
			if is_in_range(start, offset, range_tolerance, require_visibility):
				pass
			if best_route.is_empty() or (!temp_route.is_empty() and best_route.size() > temp_route.size() and offset.distance_to(end) <= range_tolerance):
				best_route = temp_route
	return best_route

## Returns true if the given grid position is considered a walkable platform.
## Check `platform_key` for more information on how this is determined.
func can_stand(grid_position: Vector3i) -> bool:
	var cell: TileData = layers[grid_position.z].get_cell_tile_data(Vector2i(grid_position.x, grid_position.y))
	var floor_cell: TileData = layers[grid_position.z - 1].get_cell_tile_data(Vector2i(grid_position.x, grid_position.y)) if grid_position.z > 0 else null
	if !cell and floor_cell and (TacGrid.platform_key.is_empty() or (floor_cell.has_custom_data(TacGrid.platform_key) and floor_cell.get_custom_data(TacGrid.platform_key))):
		return true
	return false

## Returns true if a path exists between the two given points (start and end).
## If a max_weight value over 0 is given, it will return false if the paths weight is greater than this value.
func is_navigable(start: Vector3i, end: Vector3i, max_weight: int = 0) -> bool:
	if start == end:
		return true
	var cell: TileData = get_cell_tile_data(end)
	var floor_cell: TileData = get_cell_tile_data(end + Vector3i.FORWARD)
	var route_length: int = get_route(start, end).size()
	return route_length > 0 and (route_length <= max_weight if max_weight > 0 else true)

##
func is_in_range(start: Vector3i, end: Vector3i, max_distance: float = 9999.0, require_visible: bool = false) -> bool:
	if start.distance_to(end) > max_distance:
		return false
	elif require_visible:
		var reps: int = max(abs(start.x - end.x), abs(start.y - end.y), abs(start.z - end.z))
		for i: float in reps:
			var mid: float = i / float(reps)
			var midpoint: Vector3i = Vector3i(lerp(start.x, end.x, mid), lerp(start.y, end.y, mid), lerp(start.z, end.z, mid))
			var cell: TileData = get_cell_tile_data(midpoint)
			if cell and cell.get_custom_data(TacGrid.blocking_key) and midpoint != end:
				return false
	return true

func has_intervening(start: Vector3i, end: Vector3i) -> bool:
	var reps: int = max(abs(start.x - end.x), abs(start.y - end.y), abs(start.z - end.z))
	for i: float in range(INTERVENING_DEPTH, reps):
		var mid: float = i / float(reps)
		var midpoint: Vector3i = Vector3i(lerp(start.x, end.x, mid), lerp(start.y, end.y, mid), lerp(start.z, end.z, mid))
		var cell: TileData = get_cell_tile_data(midpoint)
		if cell and midpoint != end:
			return true
	return false

func update_fog():
	var covered_tiles: Array[Vector2i]
	var cleared_tiles: Array[Vector2i]
	for viewer in get_tree().get_nodes_in_group(TacGrid.viewer_key):
		if viewer is GridNode2D:
			var pos: Vector2i = Vector2i(viewer.grid_position.x, viewer.grid_position.y)
			for x in range(max(pos.x - viewer.view_range - 1, used_rect.position.x), pos.x + viewer.view_range + 2):
				for y in range(max(pos.y - viewer.view_range - 1, used_rect.position.y), pos.y + viewer.view_range + 2):
					var tile: Vector3i = Vector3i(x, y, viewer.grid_position.z)
					var tile_2d: Vector2i = Vector2i(x, y)
					if is_in_range(viewer.grid_position, tile, viewer.view_range, true):
						cleared_tiles.push_back(tile_2d)
					elif !is_in_fog(tile):
						covered_tiles.push_back(tile_2d)
	fog_of_war.set_cells_terrain_connect(covered_tiles, 0, 0)
	fog_of_war.set_cells_terrain_connect(cleared_tiles, 0, 2)

func is_in_fog(center: Vector3i) -> bool:
	var cell: TileData = fog_of_war.get_cell_tile_data(Vector2i(center.x, center.y))
	return !cell or cell.terrain == 5

func is_highlighted(center: Vector3i) -> bool:
	var cell: TileData = highlight_layer.get_cell_tile_data(Vector2i(center.x, center.y))
	return cell != null

func clear_highlights():
	highlight_layer.clear()
	target_layer.clear()
	hover_layer.clear()

func draw_highlight(highlight: Highlight, first_area: Array[Vector2i], second_area: Array[Vector2i] = [], third_area: Array[Vector2i] = []):
	var texture: int = int(highlight)
	var layer: TileMapLayer
	match highlight:
		Map.Highlight.MOVE_HIGHLIGHT:
			layer = highlight_layer
		Map.Highlight.TARGET_HIGHLIGHT:
			layer = target_layer
		_:
			layer = hover_layer
	layer.clear()
	layer.set_cells_terrain_connect(first_area, 0, texture)
	layer.set_cells_terrain_connect(second_area, 1, texture)
	layer.set_cells_terrain_connect(third_area, 2, texture)


# PRIVATE
func _grid3d_to_id(pos: Vector3i, postfix: int = 0) -> int:
	var string: String = str(pos.x).pad_zeros(MAX_COORDINATE_SIZE) + str(pos.y).pad_zeros(MAX_COORDINATE_SIZE) + str(pos.z).pad_zeros(MAX_COORDINATE_SIZE) + (str(postfix).pad_zeros(MAX_COORDINATE_SIZE) if postfix > 0 else "")
	return string.to_int()

func _id_to_grid3d(id: int) -> Vector3i:
	var string: String = str(id).pad_zeros(MAX_COORDINATE_SIZE * 3)
	return Vector3i(string.substr(0, MAX_COORDINATE_SIZE).to_int(),
		string.substr(MAX_COORDINATE_SIZE, MAX_COORDINATE_SIZE).to_int(),
		string.substr(2 * MAX_COORDINATE_SIZE, MAX_COORDINATE_SIZE).to_int())

func _add_point(pos: Vector3i):
	var id: int = _grid3d_to_id(pos)
	var cell: TileData = layers[pos.z].get_cell_tile_data(Vector2i(pos.x, pos.y))
	nav.add_point(id, Vector3(pos))
	# Connect to existing adjacent points
	if nav.has_point(_grid3d_to_id(pos + Vector3i.LEFT)):
		nav.connect_points(id, _grid3d_to_id(pos + Vector3i.LEFT))
	if nav.has_point(_grid3d_to_id(pos + Vector3i.DOWN)):
		nav.connect_points(id, _grid3d_to_id(pos + Vector3i.DOWN))
	if pos.z > 0 and (climb_weight >= 0 or (cell and cell.has_custom_data(CLIMB_KEY))):
		var weight = cell.get_custom_data(CLIMB_KEY) if cell and cell.has_custom_data(CLIMB_KEY) else climb_weight
		# Connect to falloffs
		if nav.has_point(_grid3d_to_id(pos + Vector3i.LEFT + Vector3i.FORWARD)):
			_connect_with_weight(pos, pos + Vector3i.LEFT + Vector3i.FORWARD, weight)
		if nav.has_point(_grid3d_to_id(pos + Vector3i.DOWN + Vector3i.FORWARD)):
			_connect_with_weight(pos, pos + Vector3i.DOWN + Vector3i.FORWARD, weight)
		# Connect to climbs
		if nav.has_point(_grid3d_to_id(pos + Vector3i.RIGHT + Vector3i.FORWARD)):
			_connect_with_weight(pos, pos + Vector3i.RIGHT + Vector3i.FORWARD, weight)
		if nav.has_point(_grid3d_to_id(pos + Vector3i.UP + Vector3i.FORWARD)):
			_connect_with_weight(pos, pos + Vector3i.UP + Vector3i.FORWARD, weight)

func _connect_with_weight(start: Vector3i, end: Vector3i, weight: float):
	var i: int = 0
	while nav.has_point(_grid3d_to_id(start, i)):
		i += 1
	var new_id := _grid3d_to_id(start, i)
	nav.add_point(new_id, lerp(start, end, 0.5))
	nav.set_point_weight_scale(new_id, weight)
	nav.connect_points(_grid3d_to_id(start), new_id)
	nav.connect_points(_grid3d_to_id(end), new_id)


# SIGNALS
