@tool
class_name Footer extends RichTextLabel


# ENGINE
const PREFIX: String = "GEIST_COMM_GAMES"


# ENGINE
func _ready():
	_update_text()


# PUBLIC


# PRIVATE
func _update_text():
	text = str("[center][font_size=12]%s, %s[/font_size][/center]" % [PREFIX, Time.get_date_dict_from_unix_time(roundi(Time.get_unix_time_from_system())).year])
