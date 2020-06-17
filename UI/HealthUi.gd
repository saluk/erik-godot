extends Control

var hearts = 4 setget set_hearts
var max_hearts = 4 setget set_max_hearts

onready var label = $Label
onready var heartUiFull = $HeartUiFull
onready var heartUiEmpty = $HeartUiEmpty

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	heartUiFull.rect_size.x = hearts * 15
	
func set_max_hearts(value):
	max_hearts = max(value, 1)
	heartUiEmpty.rect_size.x = max_hearts * 15
	
func set_items(items):
	label.text = "Items:\n"
	for itemType in items.keys():
		label.text += itemType
		var count = items[itemType]
		if count > 1:
			label.text += " ["+str(count)+"]"
		label.text += "\n"

func _ready():
	print("UI READY:", PlayerStats.items)
	self.max_hearts = PlayerStats.max_health
	self.hearts = self.max_hearts
	self.set_items(PlayerStats.items)
	PlayerStats.connect("health_changed", self, "set_hearts")
	PlayerStats.connect("item_added", self, "set_items")
