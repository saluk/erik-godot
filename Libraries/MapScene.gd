extends Node2D

onready var pathSystem = $PathSystem
var scene_name

func _ready():
	SceneManager.finish_loading(self)
	pathSystem.init()
	PlayerStats.refresh()
