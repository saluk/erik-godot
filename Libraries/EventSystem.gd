extends Node

# Signal for all event types
signal add_event
# Unique signal for each event type
signal add_event_text(text)

func add_text(text):
	emit_signal("add_event")
	emit_signal("add_event_text", text)
