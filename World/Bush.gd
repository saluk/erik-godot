extends StaticBody2D

onready var collision = $CollisionShape2D

func _on_HurtBox_area_entered(area):
	queue_free()
	$BlockingObject.end()
	get_tree().get_nodes_in_group("textui")[0].set_text("Why did you have to hurt me?\nI am only a bush.")

