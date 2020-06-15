extends AnimatedSprite

func _on_HitEffect_animation_finished():
	queue_free()
