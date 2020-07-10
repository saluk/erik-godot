extends Object
class_name Files

static func filenames(path) -> Array:
	var names := []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				names.push_back(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return names

