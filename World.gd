extends Node2D

onready var pathSystem = $PathSystem

func _ready():
	pathSystem.init()

func _on_Timer_timeout():
	pathSystem.update_debug()
