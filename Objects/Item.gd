extends Area2D

export var item = 'Default'
export var canPick = true

func _ready():
	pass



func _on_area_entered(area):
	if not self.canPick:
		return
	if not area.get('damage'):
		return
	area.emit_signal('collect_item', self.item)
	SceneManager.delete(self)
