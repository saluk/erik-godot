class_name NPC
extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
onready var sprite = $Sprite
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var blinkAnimator = $BlinkAnimationPlayer
onready var pathFollower = $FollowingObject
var target = null
var path = []

var saveable = ["position","state"]
var offscreen_class = OffscreenAgent

var agent_key
func add_metadata(manager:SceneManager, scene_name):
	if not agent_key:
		var agent = manager.add_agent(self, scene_name)
		agent_key = agent.id
	SceneManager.delete(self, false, false, true)
func instanced(manager:SceneManager):
	pass
func unload(manager:SceneManager):
	if agent_key:
		var task = 'idle'
		if manager.agents.get(agent_key):
			manager.agents[agent_key].update(self, manager.current_scene, task)
	print("unloading npc", name, manager.current_scene, agent_key)

enum DESIRE_TYPE {
	SPEAKING,
	IDLE,
	USE,
	WANDER,
	GREET,
	WAITING
}

var state = DESIRE_TYPE.IDLE
var state_args = {}
var state_text := "This is my humble garden"
export var greet_distance = 64
export var desires := [
	[1, DESIRE_TYPE.GREET, {"text":"Hi there!"}],
	[2, DESIRE_TYPE.GREET, {"text":"This is the garden."}]
]
func desire_sort(a, b):
	if a[0]<b[0]:
		return true
	return false
func resolve_desire(state, state_args):
	desires.sort_custom(self, "desire_sort")
	for i in range(0, desires.size()):
		if desires[i][1] == state and ArrayFuncs.is_equal_dict(desires[i][2], state_args):
			desires.remove(i)
			return

func _ready():
	EventSystem.connect("text_cleared", self, "brain")
	
func brain():
	if desires.size()==0:
		state = pick_random_state([DESIRE_TYPE.IDLE, DESIRE_TYPE.WANDER])
		return
	desires.sort_custom(self, "desire_sort")
	var args:Array = desires[0]
	state = args[1]
	state_args = args[2]

func _physics_process(delta: float):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		DESIRE_TYPE.SPEAKING:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		DESIRE_TYPE.IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			if wanderController.get_time_left()==0:
				brain()
				wanderController.start_wander_timer(rand_range(1, 3))
		DESIRE_TYPE.WANDER:
			if wanderController.get_time_left()==0:
				brain()
				wanderController.start_wander_timer(rand_range(1, 3))
			accelerate_toward(wanderController.target_position, delta)
		DESIRE_TYPE.USE:
			if not state_args["target"]:
				for node in Nodes.find_nodes_with_property(get_tree().current_scene, "item", state_args["item"]):
					state_args["target"] = node
			else:
				# TODO - should find the closest edge on the path
				var next = pathFollower.next(global_position, 
				state_args["target"] .global_position, 
											true)
				accelerate_toward(next, delta)
				if global_position.distance_to(state_args["target"] .global_position)<=greet_distance:
					resolve_desire(state, state_args)
					return
		DESIRE_TYPE.GREET:
			var player = SceneManager.get_player()
			if player != null:
				# TODO - should find the closest edge on the path
				var next = pathFollower.next(global_position, 
											player.global_position, 
											true)
				accelerate_toward(next, delta)
				if global_position.distance_to(player.global_position)<=greet_distance:
					if  EventSystem.currentText == null:
						EventSystem.add_text(state_args["text"])
						resolve_desire(state, state_args)
						state = DESIRE_TYPE.SPEAKING
					return
	if(softCollision.is_colliding()):
		velocity += softCollision.get_push_vector() * delta * 400
	velocity = move_and_slide(velocity)
	if get_slide_count()>0:
		brain()
	
	
func accelerate_toward(point, delta):
	var dirToTarget = (point - global_position).normalized()
	sprite.flip_h = dirToTarget.x < 0
	velocity = velocity.move_toward(dirToTarget * MAX_SPEED, ACCELERATION * delta)
	if(global_position.distance_to(point)<=MAX_SPEED*0.04):
		return true
	return false
		
func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_FollowingObject_finished_path():
	pass

func _on_HurtBox_area_entered(area):
	EventSystem.add_text(state_text)
	state = DESIRE_TYPE.SPEAKING
