extends Node
var old_position
var teleport_group
var relativeVector
var in_process

func change_scene(to_scene, teleport_group=null, 
				  relativeVector=null):
	old_position = get_tree().get_nodes_in_group("player")[0].position
	in_process = true
	self.teleport_group = teleport_group
	self.relativeVector = relativeVector
	get_tree().change_scene("res://maps/"+to_scene+".tscn")

func finish_loading():
	if not in_process:
		return
	var player = get_tree().get_nodes_in_group("player")[0]
	if teleport_group:
		print(relativeVector)
		var tele = get_tree().get_nodes_in_group(teleport_group)[0]
		player.position = tele.position + tele.offset + relativeVector
