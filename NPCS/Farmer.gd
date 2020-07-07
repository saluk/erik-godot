extends NPC

var greeted = false

func create_desires():
	if not greeted:
		greeted = true
		add_desire(1, DESIRE_TYPE.GREET, {"text": "You must be Erik."})
		add_desire(2, DESIRE_TYPE.GREET, {"text": "This is my domain, I hope you are here to be useful."})
	#default desire
	if get_tree().get_nodes_in_group("carrot_spot"):
		print("Let's plant a carrot")
		add_desire(10, DESIRE_TYPE.CREATE, {"path":"res://Objects/PlantedCarrot.tscn",
											"group":"carrot_spot",
											"target":null})
