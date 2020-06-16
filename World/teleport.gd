extends Area2D

export var to_scene:String
export var teleport_group:String
export var offset:Vector2=Vector2(0,0)

func _on_Teleport_body_entered(body):
	SceneManager.change_scene(to_scene, teleport_group, 
							body.global_position-global_position)

