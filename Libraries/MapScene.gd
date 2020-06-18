extends Node2D

onready var pathSystem = $PathSystem
var scene_name
signal map_loaded(loaded_scene, scene_name)

func _ready():
	pathSystem.init()
	SceneManager.finish_loading()
	PlayerStats.refresh()
	print("emitting map_loaded")
	emit_signal("map_loaded", self, scene_name)
