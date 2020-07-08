extends NPC

var greeted = false
var greet_finished = false

func create_desires():
	if not greeted:
		greeted = true
		des.add(1, des.types.GREET, {"text": "You must be Erik."})
		des.add(2, des.types.GREET, {"text": "This is my domain, I hope you are here to be useful."})
	#default desire
	if get_tree().get_nodes_in_group("carrot_spot").size()>0:
		des.add(10, des.types.CREATE, {"path":"res://Objects/PlantedCarrot.tscn",
				"group":"carrot_spot","target":null,
				"until":rand_range(1,3), "time":0.0})
		des.add(15, des.types.IDLE, {"until":rand_range(1,2), "time":0.0})
	else:
		if not greet_finished:
			greet_finished = true
			des.add(10, des.types.GREET, {"text": "That's all the carrots planted."})
			des.add(11, des.types.GREET, {"text": "What was it you wanted?"})
		des.add(20, des.types.WANDER, {"position":null, "until":rand_range(3,10), "time":0.0})
