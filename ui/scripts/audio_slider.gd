class_name AudioSlider extends HSlider

@export_enum("Master", "Music", "Sfx") var bus: String = "Master"

@onready var audio_bus: int = AudioServer.get_bus_index(bus)


# ENGINE
func _ready():
	value = AudioServer.get_bus_volume_linear(audio_bus)
	value_changed.connect(_on_value_changed)


# PUBLIC


# PRIVATE


# SIGNALS
func _on_value_changed(new_value: float) -> void:
	SfxManager.play(SfxManager.Sfx.CLICK)
	SettingsManager.game_settings.volumes[bus] = new_value
	AudioServer.set_bus_volume_linear(audio_bus, new_value)
