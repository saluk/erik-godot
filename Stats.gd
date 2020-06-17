extends Node

export(int) var max_health = 1
export(Dictionary) var items = {}
onready var health = max_health setget set_health

func set_health(value):
	health = value
	if health <= 0:
		emit_signal("no_health")
	emit_signal("health_changed", health)
	
func refresh():
	emit_signal("health_changed", health)
	
func add_item(name):
	items[name] = items.get(name, 0) + 1
	emit_signal("item_added", items)

signal no_health
signal health_changed(value)
signal item_added(data)
