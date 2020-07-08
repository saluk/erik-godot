extends NPC

func player_talk():
	pass

func create_desires():
	if Nodes.find_nodes_with_property(get_tree().current_scene, "item", "Radish"):
		des.add(10, des.types.USE, {"item":"Radish", "target":null})
	des.add(15, des.types.WANDER, {"position":null, "until":rand_range(3,10), "time":0.0})
