class_name SaveState extends Resource

@export_storage var timestamp: Dictionary
@export_storage var beer_totals: Dictionary[String, int]
@export_storage var trinket_totals: Dictionary[String, int]


func update_timestamp():
	timestamp = Time.get_datetime_dict_from_system()

func update_level_completion(level: String, beers: int, trinkets: int):
	beer_totals[level] = max(beers, beer_totals[level] if beer_totals.has(level) else 0)
	trinket_totals[level] = max(trinkets, trinket_totals[level] if trinket_totals.has(level) else 0)

func get_total_beers() -> int:
	var tot: int = 0
	for val in beer_totals.values():
		tot += val
	return tot

func get_total_trinkets() -> int:
	var tot: int = 0
	for val in trinket_totals.values():
		tot += val
	return tot
