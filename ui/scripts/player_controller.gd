class_name PlayerController extends Controller

signal extract(beers: int, trinkets: int)

@onready var ui_container: Control = %Control
@onready var end_game_container: CenterContainer = %EndGameContainer
@onready var comp_turn_text: MarginContainer = %CompTurnText
@onready var cycle_left_button: ActionButton = %CycleLeftButton
@onready var cycle_right_button: ActionButton = %CycleRightButton
@onready var beer_button: ActionButton = %BeerButton
@onready var swipe_button: ActionButton = %SwipeButton
@onready var special_button: ActionButton = %SpecialButton
@onready var extract_button: ActionButton = %ExtractButton
@onready var beers_stolen_label: Label = %BeersStolenLabel
@onready var trinkest_stolen_label: Label = %TrinkestStolenLabel

var adjacent_beers: Array[BeerBarrel]
var adjacent_trinkets: Array[Trinket]
var dropzone: Array[Vector3i]


# ENGINE
func _unhandled_input(event: InputEvent) -> void:
	if ready_queue.is_empty() or locked_characters > 0:
		return
	if event is InputEventMouse:
		var map: Map = TacGrid.get_map()
		var target_grid: Vector3i = map.local_to_grid3d(get_viewport().get_camera_2d().get_global_mouse_position(), true)
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if !map.is_in_fog(target_grid) and ready_queue.front().move_to(target_grid):
				map.clear_highlights()
				_update()
		elif event is InputEventMouseMotion:
			if map.is_highlighted(target_grid):
				map.draw_highlight(Map.Highlight.MOVE_HOVER, [Vector2i(target_grid.x, target_grid.y)])
			else:
				map.draw_highlight(Map.Highlight.MOVE_HOVER, [])


# PUBLIC


# PRIVATE
func _update():
	ui_container.visible = locked_characters == 0
	if locked_characters > 0:
		return
	var map: Map = TacGrid.get_map()
	if ready_queue.is_empty():
		map.clear_highlights()
		_end_turn()
		return
	# Check actions left
	if ready_queue.front().actions <= 0:
		_pop_ready()
		_update()
		return
	# UI
	extract_button.disabled = !dropzone.has(ready_queue.front().grid_position)
	special_button.disabled = ready_queue.front().role == Gnome.Role.MOOK
	match ready_queue.front().role:
		Gnome.Role.SNEAK:
			special_button.icon_type = ActionButton.Icon.TELEPORT
		Gnome.Role.SPOTTER:
			special_button.icon_type = ActionButton.Icon.WARD
		Gnome.Role.DUSTER:
			special_button.icon_type = ActionButton.Icon.DUST
		_:
			special_button.icon_type = ActionButton.Icon.NONE
	cycle_left_button.disabled = ready_queue.size() == 1
	cycle_right_button.disabled = ready_queue.size() == 1
	beer_button.disabled = true
	swipe_button.disabled = true
	adjacent_beers.clear()
	adjacent_trinkets.clear()
	for entity in get_tree().get_nodes_in_group(GridNode2D.ENTITY_KEY):
		if ready_queue.front().can_see_target(entity, 1):
			if entity is BeerBarrel and !entity.expended:
				adjacent_beers.push_back(entity)
				beer_button.disabled = false
			elif entity is Trinket and !entity.stolen:
				adjacent_trinkets.push_back(entity)
				swipe_button.disabled = false
	# Highlights
	var front: Character = ready_queue.front()
	var scan_start = Vector2i(
		max(
			map.used_rect.position.x,
			front.grid_position.x - front.speed
		),
		max(
			map.used_rect.position.y,
			front.grid_position.y - front.speed
		)
	)
	var scan_end = Vector2i(
		min(
			map.used_rect.position.x + map.used_rect.size.x,
			front.grid_position.x + front.speed
		),
		min(
			map.used_rect.position.y + map.used_rect.size.y,
			front.grid_position.y + front.speed
		)
	)
	var highlight_tiles: Array[Vector2i]
	for x in range(scan_start.x, scan_end.x + 1):
		for y in range(scan_start.y, scan_end.y + 1):
			var temp: Vector3i = map.grid2d_to_grid3d(Vector2i(x, y), true)
			if front.can_travel(temp):
				highlight_tiles.push_back(Vector2i(x, y))
	map.draw_highlight(Map.Highlight.MOVE_HIGHLIGHT, highlight_tiles)
	jump_to_active()

func _end_turn():
	if get_tree().get_nodes_in_group("player").is_empty():
		_end_game()
	else:
		super()

func _start_turn():
	super()
	for character in ready_queue:
		if character.stunned_turns <= 0:
			return
	_end_game()	# If characters are all stunned or ready queue is empty, end game

func _end_game():
	MusicManager.play_leads(true)
	MusicManager.stop(true)
	# Bad practice, don't ever do this
	beers_stolen_label.text = str(get_parent().get_parent().beers)
	trinkest_stolen_label.text = str(get_parent().get_parent().trinkets)
	end_game_container.show()
	ui_container.hide()
	comp_turn_text.hide()
	if get_parent().get_parent().beers >= get_parent().get_parent().beer_quota:
		SaveStateManager.update_level_completion(get_parent().get_parent().level_name, get_parent().get_parent().beers, get_parent().get_parent().trinkets)
	else:
		beers_stolen_label.self_modulate = Color.RED


# SIGNALS
func _on_heist_turn_changed(new_turn: Heist.Turn) -> void:
	ui_container.visible = new_turn == Heist.Turn.PLAYER
	comp_turn_text.visible = new_turn == Heist.Turn.COMPUTER
	if new_turn != Heist.Turn.PLAYER:
		_turn_ended()
		return
	print("my turn!")
	_start_turn()

func _on_cycle_button_pressed(next: bool) -> void:
	if ready_queue.size() <= 1:
		return
	if next:
		ready_queue.push_back(ready_queue.pop_front())
	else:
		ready_queue.push_front(ready_queue.pop_back())
	_update()

func _on_pass_button_pressed() -> void:
	_pop_ready()
	_update()

func _on_beer_button_pressed() -> void:
	if adjacent_beers.is_empty():
		printerr("No beers adjacent! Why is this button pressable?")
		return
	for beer in adjacent_beers:
		beer.expended = true
		ready_queue.front().beers_stolen += 1
		ready_queue.front().beer_sfx.play()
	ready_queue.front().actions -= 1
	_update()

func _on_swipe_button_pressed() -> void:
	if adjacent_trinkets.is_empty():
		printerr("No trinkets adjacent! Why is this button pressable?")
		return
	for trinket in adjacent_trinkets:
		trinket.steal()
		ready_queue.front().trinkets_stolen += 1
		ready_queue.front().trinket_sfx.play()
	ready_queue.front().actions -= 1
	_update()

func _on_special_button_pressed() -> void:
	if ready_queue.front().cast_special():
		TacGrid.get_map().clear_highlights()
		ready_queue.front().ability_sfx.play()
	_update()

func _on_extract_button_pressed() -> void:
	var extracted: Character = _pop_ready()
	if extracted is Gnome:
		extract.emit(extracted.beers_stolen, extracted.trinkets_stolen)
	extracted.queue_free()
	_update()
