class_name MenuControl extends Control


# ENGINE
func _ready():
	MusicManager.play("Menu")

#func _enter_tree() -> void:
func _init() -> void:
	if SceneManager.transitioning:
		var new_transition: Transition = SceneManager.TRANSITION.instantiate()
		new_transition.fade = "in"
		add_child(new_transition)


# PUBLIC


# PRIVATE


# SIGNALS
func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
	OS.shell_open(meta)
