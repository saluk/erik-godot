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
