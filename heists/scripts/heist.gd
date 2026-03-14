class_name Heist extends Node2D

@onready var map: Map = %Map


# ENGINE
func _ready():
	map.update_fog()


# PUBLIC


# PRIVATE


# SIGNALS
