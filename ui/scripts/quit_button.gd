@tool
class_name QuitButton extends SfxButton

@export var back: bool = false:
	set(value):
		back = value
		text = "Back" if back else "Quit to Desktop"


# ENGINE


# PUBLIC


# PRIVATE


# SIGNALS
func _on_pressed() -> void:
	super()
	if back:
		SceneManager.back()
	else:
		SceneManager.quit()
