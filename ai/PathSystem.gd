extends Node

export var tileBounds:Rect2 
export var tileResolution:Vector2 = Vector2(16,16)
export var debugPath:bool
export var debugPoints:bool
export var debugConnections:bool


var _astar_map:AStar2D = AStar2D.new()
var root_map:TileMap = null
var last_astar_index:int = 0
onready var debugLines = $DebugLines
var startPos = Vector2(7,6)

func init():
	update_astar()
	
func update_astar():
	_astar_map.clear()
	add_walkable_areas()
	add_collision_areas()
	link_grid()
	update_debug()
	debug_astar()
	
func update_debug():
	if not debugLines:
		return
	if not (debugPath or debugConnections or debugPoints):
		return
	for child in debugLines.get_children():
		child.queue_free()
	debug_astar()
	
func find_path(start:Vector2, end:Vector2):
	var points = _astar_map.get_point_path(_astar_map.get_closest_point(start), 
		_astar_map.get_closest_point(end))
	var pointsAdjust = []
	for p in points:
		pointsAdjust.append(p*16+Vector2(8,8))
	if debugPath:
		var debugPoint = Line2D.new()
		debugPoint.width = 1
		debugPoint.points = PoolVector2Array(pointsAdjust)
		debugPoint.default_color = Color(0, 0, 1)
		debugLines.add_child(debugPoint)
	return pointsAdjust
	
func find_world_path(start:Vector2, end:Vector2):
	return find_path(
		Vector2(int(start.x/16),int(start.y/16)),
		Vector2(int(end.x/16),int(end.y/16))
	)
	
func debug_astar():
	if debugPoints:
		for p in _astar_map.get_points():
			var position = _astar_map.get_point_position(p)
			var debugPoint = Line2D.new()
			debugPoint.width = 2
			debugPoint.points = PoolVector2Array([position*16, 
												position*16+Vector2(2,0)])
			if _astar_map.is_point_disabled(p):
				debugPoint.default_color = Color(1, 0, 0)
			debugLines.add_child(debugPoint)
	if debugConnections:
		for p in _astar_map.get_points():
			for c in _astar_map.get_point_connections(p):
				var startPos = _astar_map.get_point_position(p)
				var endPos = _astar_map.get_point_position(c)
				var debugPoint = Line2D.new()
				debugPoint.width = 1
				debugPoint.points = PoolVector2Array([startPos*16, 
													endPos*16])
				debugPoint.default_color = Color(0, 0, 0)
				debugLines.add_child(debugPoint)
		
func add_walkable_areas():
	for ob in get_tree().get_nodes_in_group("collide_walk"):
		if not root_map:
			root_map = ob
		for tx in range(tileBounds.position.x, tileBounds.size.x-tileBounds.position.x):
			for ty in range(tileBounds.position.y, tileBounds.size.y-tileBounds.position.y):
				if ob.get_cell(tx, ty) != TileMap.INVALID_CELL:
					_add_cells(Vector2(tx, ty), ob.cell_size, true)
				elif ob == root_map:
					_add_cells(Vector2(tx, ty), ob.cell_size, false)
					
func add_collision_areas():
	for ob in get_tree().get_nodes_in_group("collide_block_tile"):
		for tile_pos in ob.get_used_cells():
			_add_cells(tile_pos, ob.cell_size, false)
	for ob in get_tree().get_nodes_in_group("collide_object"):
		if ob.is_queued_for_deletion():
			continue
		var shape:CollisionShape2D = ob.collision
		var pos = ob.global_position
		var blocking = ob.find_node("BlockingObject")
		if not blocking.is_connected("remove_collider", self, "update_astar"):
			blocking.connect("remove_collider", self, "update_astar")
		_add_cells(to_map(pos+Vector2(-shape.shape.height,0)), tileResolution, false)
		_add_cells(to_map(pos+Vector2(shape.shape.height,0)), tileResolution, false)
		_add_cells(to_map(pos+Vector2(0,-shape.shape.height)), tileResolution, false)
		_add_cells(to_map(pos+Vector2(0,shape.shape.height)), tileResolution, false)
		
func to_map(pos:Vector2):
	return Vector2(int(pos.x/tileResolution.x), int(pos.y/tileResolution.y))
		
func _add_cells(point:Vector2, cellSize:Vector2, enabled:bool):
	var stepx:int = cellSize.x/tileResolution.x
	var stepy:int = cellSize.y/tileResolution.y
	for tx in range(0,stepx):
		for ty in range(0,stepy):
			_add_point(point*Vector2(stepx,stepy)+Vector2(tx,ty), enabled)

func link_grid(diagonals:bool=false):
	for idx in _astar_map.get_points():
		var position:Vector2 = _astar_map.get_point_position(idx)
		for x in range(-1,2):
			for y in range(-1,2):
				if x==0 and y==0:
					continue
				if (x!=0 and y!=0) and not diagonals:
					continue
				link_points(idx, position+Vector2(x,y))

func link_points(idx:int, point:Vector2):
	var linkIdx:int = _astar_map.get_closest_point(point, true)
	var linkPosition:Vector2 = _astar_map.get_point_position(linkIdx)
	if linkPosition != point:
		return
	_astar_map.connect_points(idx, linkIdx, true)
			
func _add_point(point:Vector2, enabled:bool):
	var idx:int = _astar_map.get_closest_point(point, true)
	var position:Vector2
	if idx<0:
		position = point+Vector2(10,10)
	else:
		position = _astar_map.get_point_position(idx)
	if position!=point:
		_astar_map.add_point(last_astar_index, point)
		_astar_map.set_point_disabled(last_astar_index, not enabled)
		last_astar_index += 1
	else:
		toggle_point_enabled(point, enabled)

func toggle_point_enabled(point:Vector2, enabled:bool):
	var idx:int = _astar_map.get_closest_point(point, true)
	_astar_map.set_point_disabled(idx, not enabled)

