extends KinematicBody2D
const ACCELERATION = 800
const MAX_SPEED = 100
const ROLL_SPEED = 125
const FRICTION = 1000
var velocity = Vector2.ZERO
var roll_vector = Vector2.ZERO
var stats = PlayerStats

enum {
	MOVE, ROLL, ATTACK
}

var state = MOVE
onready var animPlayer = $AnimationPlayer
onready var animTree = $AnimationTree
onready var animState = $AnimationTree.get("parameters/playback")
onready var swordHitBox = $Position2D/SwordHitBox
onready var hurtBox = $HurtBox
onready var blinkAnimPlayer = $BlinkAnimationPlayer
var hasAttacked:bool = false

var saveable = ["position", "stats.health", 
				"animTree.parameters/Idle/blend_position"]

signal playerMoved

func _ready():
	blinkAnimPlayer.play("Stop")
	stats.connect("no_health", self, "queue_free")
	move_state(0.001, true)
	animTree.active = true

func _physics_process(delta: float):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)
	hasAttacked = false
			
func end_attack():
	state = MOVE
	
func end_roll():
	state = MOVE

# warning-ignore:unused_argument
func roll_state(delta: float):
	animState.travel("Roll")
	velocity = roll_vector * ROLL_SPEED
	if Input.is_action_just_pressed("attack"):
		velocity = roll_vector * ROLL_SPEED * 0.5
		state = ATTACK
	move()

# warning-ignore:unused_argument
func attack_state(delta: float):
	animState.travel("Attack")
	move()

func move_state(delta: float, vector = null):
	var input_vector = Vector2.ZERO
	if not vector:
		input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	else:
		input_vector = Vector2(0,1)
	
	if(input_vector!=Vector2.ZERO):
		roll_vector = input_vector
		swordHitBox.knockback_vector = input_vector
		animTree.set("parameters/Idle/blend_position", input_vector)
		animTree.set("parameters/Run/blend_position", input_vector)
		animTree.set("parameters/Attack/blend_position", input_vector)
		animTree.set("parameters/Roll/blend_position", input_vector)
		animState.travel("Run")
		velocity = velocity.move_toward(input_vector.normalized() * MAX_SPEED, ACCELERATION * delta)
	else:
		animState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move()
	if hasAttacked:
		velocity = Vector2.ZERO
		state = ATTACK
	if Input.is_action_just_pressed("roll"):
		state = ROLL
	
func _input(event):
	if event.is_action_pressed("attack"):
		hasAttacked = true
		get_tree().set_input_as_handled()

func move():
	velocity = move_and_slide(velocity)
	emit_signal("playerMoved")

func _on_HurtBox_area_entered(area):
	stats.health -= area.damage
	hurtBox.create_hit_effect(0)
	hurtBox.start_invincibility(1)
	return
# warning-ignore:unreachable_code
	var audio = AudioStreamPlayer.new()
	get_node("/root").add_child(audio)
	audio.set("stream", load("res://Music and Sounds/Hurt.wav"))
	audio.connect("finished", audio, "queue_free")
	audio.play()
	


func _on_HurtBox_invinsibility_started():
	blinkAnimPlayer.play("Start")


func _on_HurtBox_invinsibility_ended():
	blinkAnimPlayer.play("Stop")
