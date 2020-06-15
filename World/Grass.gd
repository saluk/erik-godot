extends Node2D

const GrassEffect = preload("res://Effects/GrassEffect.tscn")

func create_grass_effect():
	var grassEffect = GrassEffect.instance()
	grassEffect.position = position
	get_parent().add_child(grassEffect)

func _on_HurtBox_area_entered(area):
	create_grass_effect()
	queue_free()
