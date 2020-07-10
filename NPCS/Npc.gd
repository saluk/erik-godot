class_name NPC
extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200

var velocity = Vector2.ZERO
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
	
var des = Desires.new()

var state:Desires.Desire = null
var state_text := "default talking"
export var greet_distance = 64
export var interact_distance = 12
	
#Overwrite in subclass, what desire to add when we have none
func create_desires():
	assert(false)
func finish_current():
	des.remove(state)
	state = null

func _ready():
	EventSystem.connect("text_cleared", self, "finish_current")
	
func animate(mode):
	if sprite.frames.has_animation(mode):
		sprite.play(mode)
	
func brain():
	if des.is_empty():
		create_desires()
	state = des.first()

func _physics_process(delta: float):
	if state == null:
		brain()
	if $StateString.text != des.types.keys()[state.type]:
		$StateString.text = des.types.keys()[state.type]
	
	
	match state.type:
		des.types.SPEAKING:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			animate("talk")
		des.types.IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			if des.time_finished(state, delta):
				finish_current()
			animate("idle")
		des.types.WANDER:
			if not state.args["position"]:
				state.args["position"] = position
				wanderController.start_position = position
				wanderController.update_target_position()
			if des.time_finished(state, delta):
				finish_current()
			if follow_path_to(wanderController.target_position, delta, 4):
				velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			animate("idle")
		des.types.FLEE:
			if des.time_finished(state, delta):
				finish_current()
				return
			var flee_position = state.args["position"] + state.args["position"].direction_to(global_position) * 200
			if follow_path_to(flee_position, delta, 4):
				velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			animate("idle")
		des.types.USE:
			if not state.args["target"]:
				for node in Nodes.find_nodes_with_property(get_tree().current_scene, "item", state.args["item"]):
					state.args["target"] = node
			if not state.args["target"]:
				finish_current()
			else:
				if follow_path_to(state.args["target"].global_position, delta, interact_distance):
					finish_current()
					return
			animate("idle")
		des.types.CREATE:
			if not state.args["target"]:
				for node in get_tree().get_nodes_in_group(state.args["group"]):
					state.args["target"] = node
					break
			if not state.args["target"]:
				finish_current()
				print("no target, desires left",des.desires.size())
			else:
				var at_path = follow_path_to(state.args["target"].global_position, delta, interact_distance)
				var times_up = false
				if at_path:
					velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
					times_up = des.time_finished(state, delta)
				if times_up:
					var created = load(state.args["path"]).instance()
					created.position = state.args["target"].global_position
					get_parent().add_child(created)
					state.args["target"].queue_free()
					finish_current()
					return
			animate("idle")
		des.types.GREET:
			var player = SceneManager.get_player()
			if player != null:
				if follow_path_to(player.global_position, delta, greet_distance):
					if  EventSystem.currentText == null:
						EventSystem.add_text(state.args["text"])
						des.add(0, des.types.SPEAKING)
						finish_current()
					return
			else:
				des.add(0, des.types.IDLE)
			animate("idle")
	if(softCollision.is_colliding()):
		velocity += softCollision.get_push_vector() * delta * 400
	velocity = move_and_slide(velocity)
	
	
func accelerate_toward(point, delta):
	var dirToTarget = (point - global_position).normalized()
	sprite.flip_h = dirToTarget.x < 0
	velocity = velocity.move_toward(dirToTarget * MAX_SPEED, ACCELERATION * delta)
	if(global_position.distance_to(point)<=MAX_SPEED*0.04):
		return true
	return false
	
func follow_path_to(point, delta, near_distance):
	# TODO - should find the closest edge on the path
	var next = pathFollower.next(global_position, 
								point, 
								true)
	if not next:
		next = point
	if global_position.distance_to(point)<=near_distance:
		return true
	accelerate_toward(next, delta)
	return false
		
func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_FollowingObject_finished_path():
	pass

func do_interact(player):
	player_talk()

#Overwrite for different logic
func player_talk():
	if state_text:
		self.speak(state_text)
		
func speak(text):
	EventSystem.add_text(text)
	des.add(0, des.types.SPEAKING)
	brain()
