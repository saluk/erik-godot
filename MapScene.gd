extends Node2D

onready var pathSystem = $PathSystem
signal map_loaded

func _ready():
	pathSystem.init()
	SceneManager.finish_loading()
	PlayerStats.refresh()
	emit_signal("map_loaded")
