extends Area2D


func OnBigFlaskAreaEntered(body):
	var big_flask_node = get_parent()
	if big_flask_node.visible:
		var tilemap = big_flask_node.get_parent().get_parent()
		tilemap.on_big_flask_collected(big_flask_node)
