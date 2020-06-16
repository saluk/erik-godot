extends Node2D

onready var pathSystem = $PathSystem
signal map_loaded

func _ready():
	pathSystem.init()
	emit_signal("map_loaded")
	SceneManager.finish_loading()
	PlayerStats.refresh()
