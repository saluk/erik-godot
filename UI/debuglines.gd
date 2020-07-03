extends Node2D

var points:PoolVector2Array
var colors:PoolColorArray
var width:float

func _process(delta):
	update()
	
func _draw():
	for i in range(0, points.size(), 2):
		draw_line(points[i], points[i+1], colors[int(i/2.0)], width)
