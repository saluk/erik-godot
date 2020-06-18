extends Node
var teleport_group
var relativeVector
var in_process
var player_from_file

#scene_name->object_name->dictionary
#saves object states that have changed
#reapplies those states when scene loads
var objectStates = {}
var current_scene

var scenes = {}
var doors = []

func get_player():
	var player = get_tree().get_nodes_in_group("player")
	if player:
		return player[0]
	return null
	
func filename_to_scenename(filename:String):
	var lastpath = filename.split('/')[-1]
	return lastpath.split(".")[0]

func _ready():
	current_scene = get_tree().current_scene.filename
	self.call_deferred("init_universe")
	
func init_universe():
	for scene_name in ["Scene1", "Scene2"]:
		print("Loading...", scene_name)
		var loaded_resource = load("res://maps/"+scene_name+".tscn")
		scenes[scene_name] = {"scene":loaded_resource}
		var loaded_scene = loaded_resource.instance()
		get_tree().get_root().add_child(loaded_scene)
		add_metadata(loaded_scene, scene_name)
	print("finish_loading universe")
	finish_loading()
	
func add_metadata(loaded_scene, scene_name):
	for teleport in Nodes.find_nodes_in_group(loaded_scene, 'teleport'):
		doors.append([filename_to_scenename(loaded_scene.filename),
					teleport.to_scene])
	scenes[scene_name]["astar_map"] = loaded_scene.get_node("PathSystem")._astar_map
	get_tree().get_root().remove_child(loaded_scene)
	print("finish loading ",scene_name)
	print(scenes[scene_name]["astar_map"])

# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
func change_scene(to_scene, teleport_group=null, 
				  relativeVector=null):
	current_scene = to_scene
	in_process = true
	self.teleport_group = teleport_group
	self.relativeVector = relativeVector
	save_objects()
	if "res://" in to_scene:
# warning-ignore:return_value_discarded
		get_tree().change_scene(to_scene)
	else:
# warning-ignore:return_value_discarded
		get_tree().change_scene_to(scenes[to_scene]["scene"])

func finish_loading():
	load_objects()
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
