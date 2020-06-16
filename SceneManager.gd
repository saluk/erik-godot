extends Node
var old_position
var teleport_group
var keep_x
var keep_y
var in_process

func change_scene(to_scene, teleport_group=null, keep_x=false, keep_y=false):
	old_position = get_tree().get_nodes_in_group("player")[0].position
	in_process = true
	self.teleport_group = teleport_group
	self.keep_x = keep_x	
	self.keep_y = keep_y
	get_tree().change_scene("res://maps/"+to_scene+".tscn")

func finish_loading():
	if not in_process:
		return
	var player = get_tree().get_nodes_in_group("player")[0]
	if teleport_group:
		var tele = get_tree().get_nodes_in_group(teleport_group)[0]
		tele.wait_for_exit = true
		player.position = tele.position
	if keep_x:
		player.position.x = old_position.x
	if keep_y:
		player.position.y = old_position.y
