extends Control

onready var panel = $Panel
onready var panelText = $Panel/Text
var lines:Array = []

func _ready():
	EventSystem.connect("add_event_text", self, "set_text")

func _input(event):
	if not panel.visible:
		return
	if event.is_action_pressed("interact"):
		panel.visible = false
		get_tree().set_input_as_handled()
		EventSystem.emit_signal("text_cleared")

func set_text(text):
	panelText.text = text
	panel.visible = true
