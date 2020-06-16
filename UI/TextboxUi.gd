extends Control

onready var panel = $Panel
onready var panelText = $Panel/Text
var lines:Array = []

func _ready():
	var x = EventSystem.connect("add_event_text", self, "set_text")

func _input(event):
	if not panel.visible:
		return
	if event.is_action_pressed("attack"):
		panel.visible = false
		get_tree().set_input_as_handled()

func set_text(text):
	panelText.text = text
	panel.visible = true
