extends Node

class_name Serialization

static func write_serial_ob(object, data=null):
	if not data:
		data = {}
	var saveable = object.get("saveable")
	if saveable:
		for key in saveable:
			var ob = object
			for sub_ob in key.split("."):
				ob = ob.get(sub_ob)
			data[key] = ob
	return data

static func read_serial_ob(object, data):
	for key in data.keys():
		var ob = object
		var sub_obs = Array(key.split("."))
		var sub_key = sub_obs.pop_back()
		for sub_ob in sub_obs:
			ob = ob.get(sub_ob)
		ob.set(sub_key, data[key])
