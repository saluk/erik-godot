extends Node

class_name Vectors

static func get_nearest(point:Vector2, vectorList:Array) -> Vector2:
	var nearest:Vector2
	for v in vectorList:
		if not nearest:
			nearest = v
			continue
		if v.distance_to(point)<nearest.distance_to(point):
			nearest = v
	return nearest
