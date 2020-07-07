extends NPC

func _ready():
	desires = [
		[10, DESIRE_TYPE.USE, {"item":"Radish", "target":null}]
	]
