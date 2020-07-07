extends Node

# Signal for all event types
signal add_event
# Unique signal for each event type
signal add_event_text(text)
signal text_cleared

var currentText = null

func _ready():
	self.connect('text_cleared', self, 'text_cleared')

func add_text(text):
	currentText = text
	emit_signal("add_event")
	emit_signal("add_event_text", text)

func text_cleared():
	currentText = null

