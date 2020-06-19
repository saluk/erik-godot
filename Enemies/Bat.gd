extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var sprite = $BatSprite
onready var hurtbox = $HurtBox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var blinkAnimator = $BlinkAnimationPlayer
onready var pathFollower = $FollowingObject
var target = null
var path = []

var saveable = ["position","stats.health","agent_key","state"]
var offscreen_class = OffscreenAgent

var agent_key
func add_metadata(manager:SceneManager, scene_name):
	if not agent_key:
		var agent = manager.add_agent(self, scene_name)
		agent_key = agent.id
func loadinit(manager:SceneManager):
	var agent = manager.get_agent_key(self, manager.current_scene)
	if agent:
		agent_key = agent.id
	print("load bat")
func unload(manager:SceneManager):
	if agent_key:
		if state == CHASE and target:
			manager.agents[agent_key].task = "chase"
	print("unloading bat", name, manager.current_scene, agent_key)

enum {
	IDLE,
	WANDER,
	CHASE
}

var state = CHASE

func _ready():
	pass

func _physics_process(delta: float):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			if wanderController.get_time_left()==0:
				state = pick_random_state([IDLE, WANDER])
				wanderController.start_wander_timer(rand_range(1, 3))
		WANDER:
			seek_player()
			if wanderController.get_time_left()==0:
				state = pick_random_state([IDLE, WANDER])
				wanderController.start_wander_timer(rand_range(1, 3))
			accelerate_toward(wanderController.target_position, delta)
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				target = player
			if target != null:
				# TODO - should find the closest edge on the path
				var next = pathFollower.next(global_position, 
											target.global_position, 
											true)
				if next:
					accelerate_toward(next, delta)
	if(softCollision.is_colliding()):
		velocity += softCollision.get_push_vector() * delta * 400
	velocity = move_and_slide(velocity)
	if get_slide_count()>0:
		pick_random_state([IDLE, WANDER])
	
	
func accelerate_toward(point, delta):
	var dirToTarget = (point - global_position).normalized()
	sprite.flip_h = dirToTarget.x < 0
	velocity = velocity.move_toward(dirToTarget * MAX_SPEED, ACCELERATION * delta)
	if(global_position.distance_to(point)<=MAX_SPEED*0.04):
		state = pick_random_state([IDLE, WANDER])

func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE
		
func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_HurtBox_area_entered(area):
	var hit_direction = (global_position - area.global_position).normalized()
	hit_direction += area.knockback_vector.normalized()
	knockback = hit_direction.normalized() * 150
	stats.health -= area.damage
	hurtbox.create_hit_effect(16)
	hurtbox.start_invincibility(0.4)

func _on_Stats_no_health():
	var enemyDeathEffect = EnemyDeathEffect.instance()
	enemyDeathEffect.position = position + Vector2(0,-16)
	get_parent().add_child(enemyDeathEffect)
	SceneManager.delete(self)
	EventSystem.add_text("The evil bat is no more!\nYou have won.")



func _on_HurtBox_invinsibility_started():
	blinkAnimator.play("Start")


func _on_HurtBox_invinsibility_ended():
	blinkAnimator.play("Stop")


func _on_FollowingObject_finished_path():
	state = pick_random_state([IDLE, WANDER])
