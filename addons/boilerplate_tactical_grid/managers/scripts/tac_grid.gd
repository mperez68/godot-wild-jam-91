extends Node

## Grid size for all maps.
@export var grid_size: Vector2 = Vector2(16, 16)
## The custom data key to represent tiles that can be navigated on. If left empty, it assumes players can navigate on any placed tile.
@export_placeholder("None") var platform_key: String = "platform"
## The custom data key to represent tiles that block visibility. If left empty, it assumes players can see through any tile.
@export_placeholder("None") var blocking_key: String = "blocking"
## The node group key of nodes that determine cleared fog. If left empty fog is not used.
@export_placeholder("None") var viewer_key: String = "viewer"

var cached_map: Map

# PUBLIC
## Returns the first map found in the current scene (or in a given tree if provided).
func get_map() -> Map:
	return cached_map if is_instance_valid(cached_map) else _get_map(get_tree().current_scene)


# PRIVATE
func _get_map(parent: Node) -> Map:
	if !parent:
		return
	if parent is Map:
		return parent
	for child in parent.get_children():
		var ret = _get_map(child)
		if ret != null:
			return ret
	return null
