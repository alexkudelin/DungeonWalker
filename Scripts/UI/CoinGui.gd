extends Area2D


func OnCoinAreaEntered(body):
#	var world = get_parent().get_parent().get_parent()
#	var pos = tilemap.world_to_map(body.position)
#	tilemap.set_cellv(pos, -1)
	if get_parent().visible:
#		if body.get_name() == "Player":
		get_parent().visible = false

		print("coin in")


func OnCoinAreaExited(_body):
	print("coin out")
