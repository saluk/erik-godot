extends Object
class_name Desires

enum types {
	IDLE,
	SPEAKING,
	USE,
	WANDER,
	GREET,
	CREATE,
	WAITING
}

class Desire:
	extends Reference
	var type:int = types.IDLE
	var priority:int
	var meet_required_f:FuncRef
	var operate_f:FuncRef
	var args:Dictionary

var desires := []

func is_empty():
	return desires.size()==0

func _desire_sort(a:Desire, b:Desire):
	if a.priority<b.priority:
		return true
	return false

func sort():
	desires.sort_custom(self, "_desire_sort")

func remove(d:Desire):
	desires.erase(d)

func first():
	sort()
	if is_empty():
		return null
	return desires[0]

func add(priority:int, desire:int, arg:Dictionary={}) -> Desire:
	var d = Desire.new()
	d.type = desire
	d.priority = priority
	d.args = arg
	desires.append(d)
	return d

func time_finished(d:Desire, delta:float) -> bool:
	d.args["time"] += delta
	if d.args["time"] > d.args["until"]:
		return true
	return false
