extends Node
var teleport_group
var relativeVector
var in_process

signal done_loading

var ui_scene = load("res://UI/UI.tscn")

var agentTimer:Timer
var AGENT_INTERVAL := 0.25

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
func change_agent_scene(id, scene_name, teleport_group=null):
	scene_name = get_scene_path(scene_name)
	var agent = agents[id]
	agent.scene_name = scene_name
	if scene_name != current_scene:
		print("Moved to another offloaded scene")
		return
	instance_agent(agent, teleport_group)
func instance_agent(agent:OffscreenAgent, teleport_group=null):
	print("instancing", agent.id, agent.data)
	var node = load(agent.instance_type).instance()
	node.agent_key = agent.id
	get_tree().current_scene.get_node('Objects').add_child(node)
	Serialization.read_serial_ob(node, agent.data)
	if teleport_group:
		var tele = get_tree().get_nodes_in_group(teleport_group)[0]
		node.position = tele.position + tele.offset
	else:
		node.position = agent.position
	print("node key:",node.agent_key)
	node.instanced(self)

func _process_agents(_delta):
	for agent in agents.values():
		if agent.scene_name != current_scene:
			agent._process(_delta)

func get_player():
	var player = get_tree().get_nodes_in_group("player")
	if player:
		return player[0]
	return null

func _ready():
	agentTimer = Timer.new()
	current_scene = get_tree().current_scene.filename
	self.call_deferred("init_universe")
	
func init_universe():
	# Timer's only work when added to the scene
	get_tree().get_root().add_child(agentTimer)
	var fader:Node = load("res://UI/Fader.tscn").instance()
	get_tree().get_root().add_child(fader)
	agentTimer.start(AGENT_INTERVAL)
	agentTimer.connect("timeout", self, "_process_agents", [AGENT_INTERVAL])
	var original_scene:String = current_scene
	var file_names := []
	for file_name in Files.filenames("res://maps/"):
		if String(file_name).ends_with(".tscn"):
			file_names.push_back("res://maps/"+file_name)
	if not original_scene in file_names:
		file_names.push_back(original_scene)
	for file_name in file_names:
		print("Loading...", file_name)
		var loaded_resource = load(file_name)
		scenes[file_name] = {
			"scene":loaded_resource,
			"astar_map": AStar2D.new()
		}
		current_scene = file_name
		var loaded_scene = loaded_resource.instance()
		get_tree().get_root().add_child(loaded_scene)
		add_metadata(loaded_scene, file_name)
	print("finish_loading universe")
	print(scenes)
	print("original scene:",original_scene)
	change_scene(original_scene)
	pause_scene()
	(fader.find_node("AnimationPlayer") as AnimationPlayer).play("fadeup")
	yield(fader.find_node("AnimationPlayer"), "animation_finished")
	unpause_scene()
	
func pause_scene():
	get_tree().paused = true
	
func unpause_scene():
	get_tree().paused = false
	
func add_metadata(loaded_scene:Node, scene_name:String):
	loaded_scene.propagate_call("add_metadata", [self, scene_name])
	get_tree().get_root().remove_child(loaded_scene)
	loaded_scene.queue_free()
	print("finish loading ",scene_name)
	print(scenes[scene_name])
	
func get_metadata():
	if not scenes.has(current_scene):
		print("-> create new scene metadata:", current_scene)
		print(scenes)
		print(current_scene)
		scenes[current_scene] = {
			"astar_map": AStar2D.new()
		}
	return scenes[current_scene]
	
func get_scene_path(name):
	if not "res://" in name:
		name = "res://maps/"+name+".tscn"
	return name

# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
func change_scene(to_scene, teleport_group=null, 
				  relativeVector=null):
	to_scene = get_scene_path(to_scene)
	in_process = true
	self.teleport_group = teleport_group
	self.relativeVector = relativeVector
	save_objects()
	current_scene = to_scene
	print("Changed scene:",current_scene)
	print("scenes:",scenes)
	get_tree().change_scene_to(scenes[to_scene]["scene"])

func finish_loading(scene):
	load_objects()
	scene.add_child(ui_scene.instance())
	if not in_process:
		emit_signal("done_loading")
		return
	var player = get_player()
	if teleport_group and player:
		var tele = get_tree().get_nodes_in_group(teleport_group)[0]
		player.position = tele.position + tele.offset + relativeVector
		teleport_group = null
	emit_signal("done_loading")
		
func save_object_change(object, states, ob_name="", scene_name=""):
	if not states:
		return
	if not ob_name:
		ob_name = object.name
	if not scene_name:
		scene_name = get_tree().current_scene.filename
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
	for object in tree.get_children():
		load_objects(object)
		var states = objectStates.get(scene_name,{}).get(object.name,{})
		if states.get("_delete", false):
			object.queue_free()
			continue
		Serialization.read_serial_ob(object, states)
	if tree == get_tree().current_scene:
		for agent in agents.values():
			if agent.scene_name == current_scene:
				instance_agent(agent)
			
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
		
func delete(object:Node, delete_agent=true, delete_object=true, save_deletion=true):
	print("delete ",object, " ", delete_agent, " ", delete_object, " ", save_deletion)
	if save_deletion:
		self.save_object_change(object, {"_delete":true})
	if delete_object:
		object.queue_free()
	if delete_agent:
		if object.get('agent'):
			if agents.get(object.agent.id,null):
				agents.erase(object.agent.id)
				

func _input(event):
	if event.is_action_pressed("quick_save_1") and get_player():
		save_objects(null, true)
		var file = File.new()
		file.open("user://erik_1.sav",File.WRITE)
		var save_agents = {}
		for agent in agents.values():
			save_agents[agent.id] = Serialization.write_serial_ob(agent)
		var saved = {
			'objectStates':objectStates,
			'current_scene':current_scene,
			'agents':save_agents,
			'player':Serialization.write_serial_ob(get_player())
		}
		file.store_var(saved)
		file.close()
	elif event.is_action_pressed("quick_load_1"):
		print("BEGIN LOAD")
		print(scenes["Scene2"]["astar_map"].get_points().size())
		print(current_scene)
		print(get_tree().current_scene)
		get_tree().current_scene.queue_free()
		yield(get_tree().current_scene, "tree_exited")
		print(scenes["Scene2"]["astar_map"].get_points().size())
		var file = File.new()
		file.open("user://erik_1.sav",File.READ)
		var saved = file.get_var()
		file.close()
		print(saved)
		var load_agents = saved['agents']
		agents = {}
		objectStates = {}
		objectStates = saved['objectStates']
		get_tree().change_scene_to(scenes[saved['current_scene']]['scene'])
		yield(self, "done_loading")
		for scene in scenes.keys():
			print("scene:",scene, ", points", scenes[scene]['astar_map'].get_points().size())
		for agent_key in load_agents.keys():
			agents[agent_key] = OffscreenAgent.new()
			Serialization.read_serial_ob(agents[agent_key], load_agents[agent_key])
		load_objects()
		Serialization.read_serial_ob(get_player(), saved['player'])
