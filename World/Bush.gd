extends StaticBody2D

onready var collision = $CollisionShape2D

func _on_HurtBox_area_entered(area):
	queue_free()
	$BlockingObject.end()
	EventSystem.add_text("Why did you have to hurt me?\nI am only a bush.")

