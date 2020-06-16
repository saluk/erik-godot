extends Node
var old_position
var teleport_group
var relativeVector
var in_process

#scene_name->object_name->dictionary
#saves object states that have changed
#reapplies those states when scene loads
var objectStates = {}

func change_scene(to_scene, teleport_group=null, 
				  relativeVector=null):
	old_position = get_tree().get_nodes_in_group("player")[0].position
	in_process = true
	self.teleport_group = teleport_group
	self.relativeVector = relativeVector
	save_objects()
	get_tree().change_scene("res://maps/"+to_scene+".tscn")

func finish_loading():
	load_objects()
	if not in_process:
		return
	var player = get_tree().get_nodes_in_group("player")[0]
	if teleport_group:
		print(relativeVector)
		var tele = get_tree().get_nodes_in_group(teleport_group)[0]
		player.position = tele.position + tele.offset + relativeVector
		
func save_object_change(object, states):
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
		for key in states.keys():
			object.set(key, states[key])
			
func save_objects(tree=null):
	var scene_name = get_tree().current_scene.filename
	if not tree:
		tree = get_tree().current_scene
	for object in tree.get_children():
		save_objects(object)
		var states = objectStates.get(scene_name,{}).get(object.name,{})
		var saveable = object.get("saveable")
		if saveable:
			for key in saveable:
				states[key] = object.get(key)
		save_object_change(object, states)
		
func delete(object):
	self.save_object_change(object, {"_delete":true})
	object.queue_free()
