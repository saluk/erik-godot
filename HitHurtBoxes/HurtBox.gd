extends Area2D

const HitEffect = preload("res://Effects/HitEffect.tscn")

onready var timer = $Timer
onready var collisionShape = $CollisionShape2D
var invinsible = false setget set_invincible
signal invinsibility_started
signal invinsibility_ended

func set_invincible(value):
	invinsible = value
	if invinsible == true:
		emit_signal("invinsibility_started")
	else:
		emit_signal("invinsibility_ended")

func start_invincibility(duration):
	timer.start(duration)
	self.invinsible = true
	
func create_hit_effect(offsety:int):
	var effect = HitEffect.instance()
	var main = get_tree().current_scene
	main.add_child(effect)
	effect.global_position = global_position - Vector2(0, offsety)


func _on_Timer_timeout():
	self.invinsible = false


func _on_HurtBox_invinsibility_ended():
	collisionShape.set_deferred("Disabled", false)


func _on_HurtBox_invinsibility_started():
	collisionShape.set_deferred("Disabled", true)

func do_interact(player):
	get_parent().do_interact(player)
