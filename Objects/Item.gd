extends Area2D
class_name Item

export var item = 'Default'
export var canPick = true
export var isTool = false

func _ready():
	pass


func do_interact(player):
	if self.canPick:
		player.collect_item(self.item)
	elif self.isTool:
		if not player.collect_tool(self):
			return
	else:
		return
	SceneManager.delete(self)
