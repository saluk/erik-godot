extends Area2D

export var item = 'Default'

func _ready():
	pass



func _on_area_entered(area):
	if not area.get('damage'):
		return
	area.emit_signal('collect_item', self.item)
	SceneManager.delete(self)
