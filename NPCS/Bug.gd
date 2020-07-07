extends NPC

func create_desires():
	if Nodes.find_nodes_with_property(get_tree().current_scene, "item", "Radish"):
		add_desire(10, DESIRE_TYPE.USE, {"item":"Radish", "target":null})
	add_desire(15, DESIRE_TYPE.WANDER, {})
