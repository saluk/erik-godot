extends StaticBody2D

onready var collision = $CollisionShape2D

const BushEffect = preload("res://Effects/BushEffect.tscn")

func create_effect():
	var bushEffect = BushEffect.instance()
	bushEffect.position = position
	bushEffect.emitting = true
	bushEffect.one_shot = true
	get_parent().add_child(bushEffect)

func _on_HurtBox_area_entered(area):
	create_effect()
	SceneManager.delete(self)
	$BlockingObject.end()
	EventSystem.add_text("Why did you have to hurt me?\nI am only a bush.")
	
