extends Node2D

onready var pathSystem = $PathSystem
var scene_name
var is_map = true

func _ready():
	pathSystem.init()
	SceneManager.finish_loading(self)
	PlayerStats.refresh()
