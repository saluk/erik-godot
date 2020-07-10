extends Node

class_name Nodes

static func walk_all_nodes(n:Node):
	var nodes = [n]
	var found = []
	while nodes.size()>0:
		var cur:Node = nodes.pop_front()
		found.append(cur)
		for child in cur.get_children():
			nodes.append(child)
	return found

static func find_nodes_in_group(n:Node, group:String):
	var nodes = [n]
	var found = []
	while nodes.size()>0:
		var cur:Node = nodes.pop_front()
		if cur.is_in_group(group):
			found.append(cur)
		for child in cur.get_children():
			nodes.append(child)
	return found

static func find_nodes_with_property(n:Node, p:String, val):
	var nodes = [n]
	var found = []
	while nodes.size()>0:
		var cur:Node = nodes.pop_front()
		if cur.get(p) == val:
			found.append(cur)
		for child in cur.get_children():
			nodes.append(child)
	return found

static func find_nearest(position:Vector2, nodes:Array):
	var nearest:Node2D = null
	var nearest_distance := 0
	for node in nodes:
		var distance = position.distance_squared_to(node.global_position)
		if not nearest or distance<nearest_distance:
			nearest = node
			nearest_distance = distance
	return nearest
	

class DistanceSorter:
	extends Reference
	var _position_for_sort:Vector2
	func sort(a:Node2D, b:Node2D):
		var distance_squared_a = a.position.distance_squared_to(_position_for_sort)
		var distance_squared_b = b.position.distance_squared_to(_position_for_sort)
		if distance_squared_a<distance_squared_b:
			return true
		return false

static func sort_by_distance(position:Vector2, nodes:Array):
	var sorter = DistanceSorter.new()
	sorter._position_for_sort = position
	nodes.sort_custom(sorter, "sort")
	
