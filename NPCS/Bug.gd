extends NPC

func player_talk():
	pass

func create_desires():
	if Nodes.find_nodes_with_property(get_tree().current_scene, "item", "Radish"):
		des.add(10, des.types.USE, {"item":"Radish", "target":null})
	des.add(15, des.types.WANDER, {"position":null, "until":rand_range(3,10), "time":0.0})


func _on_HurtBox_area_entered(area:Area2D):
	print(area)
	if not area.get("signal_type"):
		return
	if area.signal_type == "spray":
		if state.type == des.types.FLEE:
			finish_current()
		des.add(0, des.types.FLEE, {"position":area.global_position, "until":rand_range(5,10), "time":0.0})
		brain()
