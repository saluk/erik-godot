extends Particles2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if not emitting:
		queue_free()
