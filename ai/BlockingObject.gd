extends Node

signal remove_collider

func end():
	emit_signal("remove_collider")
