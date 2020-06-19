extends Node
var teleport_group
var relativeVector
var in_process
var player_from_file

var ui_scene = load("res://UI/UI.tscn")

#scene_name->object_name->dictionary
#saves object states that have changed
#reapplies those states when scene loads
var objectStates = {}
var agents = {}
var current_scene

var scenes = {}

func add_agent(node, scene_name) -> String:
	var agent = OffscreenAgent.new()
	agent.update(node, scene_name)
	agents[agent.id] = agent
	return agent
func get_agent_key(node, scene_name):
	return agents.get(OffscreenAgent.make_key(node, scene_name), null)
func change_agent_scene(id, scene_name, teleport_group):
	var agent = agents[id]
	agent.scene_name = scene_name
	if scene_name != current_scene:
		print("Moved to another offloaded scene")
		return
	print("instancing", agent)
	var node = load(agent.instance_type).instance()
	node.agent_key = agent.id
	var tele = get_tree().get_nodes_in_group(teleport_group)[0]
	node.position = tele.position + tele.offset
	node.state = node.CHASE
	node.get_node("PlayerDetectionZone/CollisionShape2D").shape.radius = 168
	get_tree().current_scene.get_node('Objects').add_child(node)
	
func _process(_delta):
	for agent in agents.values():
		if agent.scene_name != current_scene:
			agent._process(_delta)

func get_player():
	var player = get_tree().get_nodes_in_group("player")
	if player:
		return player[0]
	return null
	
func filename_to_scenename(filename:String):
	var lastpath = filename.split('/')[-1]
	return lastpath.split(".")[0]

func _ready():
	current_scene = filename_to_scenename(get_tree().current_scene.filename)
	self.call_deferred("init_universe")
	
func init_universe():
	for scene_name in ["Scene1", "Scene2"]:
		print("Loading...", scene_name)
		var loaded_resource = load("res://maps/"+scene_name+".tscn")
		scenes[scene_name] = {
			"scene":loaded_resource,
			"astar_map": AStar2D.new()
		}
		var loaded_scene = loaded_resource.instance()
		get_tree().get_root().add_child(loaded_scene)
		add_metadata(loaded_scene, scene_name)
	print("finish_loading universe")
	change_scene(current_scene)
	
func add_metadata(loaded_scene:Node, scene_name:String):
	loaded_scene.propagate_call("add_metadata", [self, scene_name])
	get_tree().get_root().remove_child(loaded_scene)
	print("finish loading ",scene_name)
	print(scenes[scene_name])
	
func get_metadata():
	if not scenes.has(current_scene):
		return {}
	return scenes[current_scene]

# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
func change_scene(to_scene, teleport_group=null, 
				  relativeVector=null):
	in_process = true
	self.teleport_group = teleport_group
	self.relativeVector = relativeVector
	save_objects()
	current_scene = to_scene
	if "res://" in to_scene:
# warning-ignore:return_value_discarded
		get_tree().change_scene(to_scene)
	else:
# warning-ignore:return_value_discarded
		get_tree().change_scene_to(scenes[to_scene]["scene"])

func finish_loading(scene):
	load_objects()
	scene.add_child(ui_scene.instance())
	if not in_process:
		return
	var player = get_player()
	if teleport_group and player:
		var tele = get_tree().get_nodes_in_group(teleport_group)[0]
		player.position = tele.position + tele.offset + relativeVector
		teleport_group = null
	if player_from_file:
		Serialization.read_serial_ob(get_player(),player_from_file)
		player_from_file = null
		
func save_object_change(object, states):
	if not states:
		return
	var scene_name = get_tree().current_scene.filename
	var ob_name = object.name
	if not objectStates.has(scene_name):
		objectStates[scene_name] = {}
	var sceneObjects = objectStates[scene_name]
	if not sceneObjects.has(ob_name):
		sceneObjects[ob_name] = {}
	var old_object = sceneObjects[ob_name]
	for key in states.keys():
		old_object[key] = states[key]
		
func load_objects(tree=null):
	var scene_name = get_tree().current_scene.filename
	if not tree:
		tree = get_tree().current_scene
		tree.propagate_call("loadinit", [self])
	for object in tree.get_children():
		load_objects(object)
		var states = objectStates.get(scene_name,{}).get(object.name,{})
		if states.get("_delete", false):
			object.queue_free()
			continue
		Serialization.read_serial_ob(object, states)
			
func save_objects(tree=null, save_player=false):
	var scene_name = get_tree().current_scene.filename
	if not tree:
		tree = get_tree().current_scene
		tree.propagate_call("unload", [self])
	for object in tree.get_children():
		if not save_player and object.name == 'Player':
			continue
		save_objects(object)
		var states = objectStates.get(scene_name,{}).get(object.name,{})
		save_object_change(object, Serialization.write_serial_ob(object, states))
		
func delete(object):
	self.save_object_change(object, {"_delete":true})
	object.queue_free()

func _input(event):
	if event.is_action_pressed("quick_save_1") and get_player():
		save_objects(null, true)
		var file = File.new()
		file.open("user://erik_1.sav",File.WRITE)
		var saved = {
			'objectStates':objectStates,
			'current_scene':current_scene,
			'player':Serialization.write_serial_ob(get_player())
		}
		file.store_var(saved)
		file.close()
	elif event.is_action_pressed("quick_load_1"):
		var file = File.new()
		file.open("user://erik_1.sav",File.READ)
		var saved = file.get_var()
		file.close()
		print(saved)
		objectStates = saved['objectStates']
		player_from_file = saved['player']
		load_objects()
		Serialization.read_serial_ob(get_player(), player_from_file)
		change_scene(saved['current_scene'])
