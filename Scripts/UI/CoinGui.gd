extends Area2D


func OnCoinAreaEntered(body):
	var coin_node = get_parent()
	if coin_node.visible:
		var tilemap = coin_node.get_parent().get_parent()
		tilemap.on_coin_collected(coin_node)
