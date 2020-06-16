extends Area2D

export var to_scene:String
export var teleport_group:String
export var keep_x:bool
export var keep_y:bool

var wait_for_exit = false

func _on_Teleport_body_entered(body):
	if not wait_for_exit:
		SceneManager.change_scene(to_scene, teleport_group, keep_x, keep_y)


func _on_Teleport_body_exited(body):
	wait_for_exit = false
