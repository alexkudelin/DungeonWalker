extends Area2D


func OnSmallFlaskAreaEntered(body):
	var small_flask_node = get_parent()
	if small_flask_node.visible:
		var tilemap = small_flask_node.get_parent().get_parent()
		tilemap.on_small_flask_collected(small_flask_node)
