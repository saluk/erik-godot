extends Node

export var tolerance:int = 8
var pathSystem
var currentPath = null

signal finished_path

func get_path_system():
	if pathSystem:
		return pathSystem
	pathSystem = get_tree().get_nodes_in_group("PathSystem")[0]
	return pathSystem

func find_path(posA, posB):
	if not get_path_system(): return
	return pathSystem.find_world_path(posA, posB)

func next(posA, posB, recalculate=false):
	if recalculate or not currentPath:
		currentPath = find_path(posA, posB)
	if not currentPath:
		return
	var next_point = currentPath[0]
	if posA.distance_to(next_point)<=tolerance:
		currentPath.remove(0)
		if not currentPath:
			emit_signal("finished_path")
			currentPath = null
			return
		next_point = currentPath[0]
	return next_point
