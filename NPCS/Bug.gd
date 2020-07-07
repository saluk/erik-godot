extends NPC

func create_desires():
	add_desire(10, DESIRE_TYPE.USE, {"item":"Radish", "target":null})
	add_desire(15, DESIRE_TYPE.WANDER, {})
