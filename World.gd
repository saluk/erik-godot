extends Node2D

signal world_ready

func _ready():
	emit_signal("world_ready")
