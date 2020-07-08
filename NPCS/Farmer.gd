extends NPC

var greeted = false
var greet_finished = false

func player_talk():
	if not greet_finished:
		speak("I said don't get in my way. Scram!")
	else:
		speak("Yeah, sure. You can take the carrots.")

func create_desires():
	if not greeted:
		greeted = true
		des.add(1, des.types.GREET, {"text": "What's your name? Erik?"})
		des.add(2, des.types.GREET, {"text": "What are ya even here for..."})
		des.add(3, des.types.IDLE, {"until":1, "time":0.0})
		des.add(4, des.types.GREET, {"text": "I don't care what ya do - "})
		des.add(5, des.types.GREET, {"text": "Just don't get in my way."})
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
