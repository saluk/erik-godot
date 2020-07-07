extends Node

class_name ArrayFuncs

static func map(a:Array, f:FuncRef):
	for i in range(a.size()):
		a[i] = f.call_func(a[i])

static func find_nodes_in_group(var n:Node, var group:String):
	var nodes = [n]
	var found = []
	while nodes.size()>0:
		var cur:Node = nodes.pop_front()
		if cur.is_in_group(group):
			found.append(cur)
		for child in cur.get_children():
			nodes.append(child)
	return found

static func is_equal_array(var a:Array, var b:Array):
	pass

static func is_equal_dict(var a:Dictionary, var b:Dictionary):
	var ak = a.keys()
	var bk = b.keys()
	for k in ak:
		if not b.has(k):
			return false
		if a[k] != b[k]:
			return false
	for k in bk:
		if not a.has(k):
			return false
	return true
		
