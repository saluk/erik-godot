extends Control

onready var panel = $Panel
onready var panelText = $Panel/Text

func _input(event):
	if not panel.visible:
		return
	if event.is_action("attack"):
		panel.visible = false
		get_tree().set_input_as_handled()

func set_text(text):
	panelText.text = text
	panel.visible = true
