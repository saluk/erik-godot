extends Node

class_name OffscreenAgent
var id:String
var task:String = "idle"
var position:Vector2 = Vector2(0,0)
var data:Dictionary = {}
var scene_name:String = ""
var speed = 64
var instance_type = ""

var saveable = ["id", "task", "position", "data", "scene_name", "speed", "instance_type"]

static func make_key(node, scene_name):
	return node.name+":"+scene_name

func update(node:Node, scene_name, task='idle'):
	name = node.name
	self.scene_name = scene_name
	self.task = task
	self.position = node.position
	self.instance_type = node.filename
	self.data = Serialization.write_serial_ob(node)
	if id.empty():
		id = make_key(node, scene_name)

func _process(delta):
	match task:
		'idle':
			pass
		'chase':
			chase_action(delta)
		_:
			pass
			
func get_scene_meta():
	return SceneManager.scenes[scene_name]

func find_path(_astar_map:AStar2D, start:Vector2, end:Vector2):
	var points = _astar_map.get_point_path(
		_astar_map.get_closest_point(start), 
		_astar_map.get_closest_point(end))
	var pointsAdjust = []
	for p in points:
		pointsAdjust.append(p*16+Vector2(8,8))
	return pointsAdjust
	
func find_world_path(_astar_map, start:Vector2, end:Vector2):
	return find_path(
		_astar_map,
		Vector2(int(start.x/16),int(start.y/16)),
		Vector2(int(end.x/16),int(end.y/16))
	)
	
func next(currentPath):
	if not currentPath:
		print("no path")
		return
	var next_point = currentPath[0]
	if position.distance_to(next_point)<=16:
		currentPath.remove(0)
		if not currentPath:
			print("removed last point")
			return
		next_point = currentPath[0]
	return next_point
	
func follow_path(_astarMap, delta, destination):
	var path = find_world_path(_astarMap, position, destination)
	if not path:
		return
	var np = next(path)
	if not np:
		return true
	position += position.direction_to(np) * speed * delta

func chase_action(delta):
	var meta = get_scene_meta()
	var astar = meta['astar_map']
	var player = SceneManager.get_player()
	for door in meta.get('doors', []):
		if SceneManager.get_scene_path(door[0]) == SceneManager.current_scene:
			if follow_path(astar, delta, door[1]):
				task = "idle"
				SceneManager.change_agent_scene(id, door[0], door[2])
			else:
				pass
				#print("following", position, door[1])
			return
			
