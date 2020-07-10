extends Item

const SprayFromCan = preload("res://Effects/sprayfromcan.tscn")

func do_use(player:Node2D, direction:Vector2):
	var spray = SprayFromCan.instance()
	spray.velocity = player.velocity+direction*20
	player.get_parent().add_child(spray)
	spray.global_position = global_position + direction*5
