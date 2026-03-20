@tool
class_name GatedButton extends SceneChangeButton

@export var beers_required: int = 0


# ENGINE


# PUBLIC


# PRIVATE
func _update_text():
	if  !Engine.is_editor_hint() and SaveStateManager.save_state.get_total_beers() < beers_required:
		disabled = true
		text = "%s beers" % beers_required
		return
	else:
		disabled = false
	super()


# SIGNALS
