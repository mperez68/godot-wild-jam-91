class_name LevelSelect extends MenuControl

@onready var beers_label: Label = %BeersLabel
@onready var trinkets_label: Label = %TrinketsLabel


# ENGINE
func _ready():
	SaveStateManager.load_game_state()
	beers_label.text = str("%s Beers Stolen" % SaveStateManager.save_state.get_total_beers())
	trinkets_label.text = str("%s Trinkets Stolen" % SaveStateManager.save_state.get_total_trinkets())
	super()
	MusicManager.play_leads(true)


# PUBLIC


# PRIVATE


# SIGNALS
