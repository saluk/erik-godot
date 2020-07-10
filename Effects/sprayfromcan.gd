extends Area2D

var velocity:Vector2
var signal_type = "spray"

func _physics_process(delta):
	position += velocity*delta


func _on_Timer_timeout():
	queue_free()
