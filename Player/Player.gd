extends KinematicBody2D
const ACCELERATION := 800
const MAX_SPEED := 100
const ROLL_SPEED := 125
const FRICTION := 1000
var velocity := Vector2.ZERO
var stats := PlayerStats

enum {
	MOVE, ROLL, INTERACT, USE, GET, DROP
}

var state = MOVE
onready var animPlayer = $AnimationPlayer
onready var animTree = $AnimationTree
onready var animState = $AnimationTree.get("parameters/playback")
onready var swordHitBox = $Position2D/SwordHitBox
onready var hurtBox = $HurtBox
onready var blinkAnimPlayer = $BlinkAnimationPlayer
onready var interactionArea = find_node("InteractionArea")
onready var equippedTool = find_node("EquippedTool")

var saveable := ["position", "stats.health", 
				"animTree.parameters/Idle/blend_position",
				"stats.items"]

var facing := Vector2.ZERO
var can_interact := []

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
		INTERACT:
			interact_state(delta)
		USE:
			interact_state(delta)
		GET:
			interact_state(delta)
		DROP:
			interact_state(delta)
	
func end_roll():
	state = MOVE

func roll_state(delta: float):
	animState.travel("Roll")
	velocity = facing * ROLL_SPEED
	if Input.is_action_just_pressed("interact"):
		velocity = facing * ROLL_SPEED * 0.5
	move()

func interact_state(delta: float):
	pass

func move_state(delta: float, vector = null):
	var input_vector = Vector2.ZERO
	if not vector:
		input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	else:
		input_vector = Vector2(0,1)
	
	if(input_vector!=Vector2.ZERO):
		facing = input_vector
		swordHitBox.knockback_vector = input_vector
		interactionArea.position = input_vector * 10
		equippedTool.position = input_vector * 10
		animTree.set("parameters/Idle/blend_position", input_vector)
		animTree.set("parameters/Run/blend_position", input_vector)
		animTree.set("parameters/Roll/blend_position", input_vector)
		animState.travel("Run")
		velocity = velocity.move_toward(input_vector.normalized() * MAX_SPEED, ACCELERATION * delta)
	else:
		animState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move()
	if Input.is_action_just_pressed("roll"):
		state = ROLL
	
func _input(event):
	if get_tool():
		tool_input(event)
	else:
		no_tool_input(event)

func tool_input(event):
	var currentTool = get_tool()
	if event.is_action_pressed("use"):
		if currentTool.has_method("do_use"):
			currentTool.do_use(self, facing)
			get_tree().set_input_as_handled()
			return
	if event.is_action_pressed("drop"):
		print("drop tool")
		equippedTool.remove_child(currentTool)
		var instance = load(currentTool.filename).instance()
		instance.global_position = global_position
		get_parent().add_child(instance)
		get_tree().set_input_as_handled()
		return

func no_tool_input(event):
	if event.is_action_pressed("interact"):
		Nodes.sort_by_distance(global_position, can_interact)
		for item in can_interact:
			if item.has_method("do_interact"):
				item.do_interact(self)
				get_tree().set_input_as_handled()
				return

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

func get_tool() -> Node2D:
	if equippedTool.get_child_count()>0:
		return equippedTool.get_child(0)
	return null

func collect_item(itemName):
	stats.add_item(itemName)
	
func collect_tool(toolItem:Node2D):
	if get_tool():
		return false
	var currentTool = load(toolItem.filename).instance()
	equippedTool.add_child(currentTool)
	return true


func _on_InteractionArea_area_entered(area):
	can_interact.push_back(area)


func _on_InteractionArea_area_exited(area):
	can_interact.erase(area)
