class_name CARoom

var Constants = load("res://Scripts/Utils/Constants.gd")

var x = null
var y = null
var width = null setget set_width, get_width
var height = null setget set_height, get_height

var ca = null


func x1():
	return self.x

func x2():
	return self.x + self.width - 1

func y1():
	return self.y

func y2():
	return self.y + self.height - 1

func set_width(new_width):
	width = new_width

func get_width():
	return width

func set_height(new_height):
	height = new_height

func get_height():
	return height

func get_boundary_box():
	var h = ca.matrix.size()
	var w = ca.matrix[0].size()

	var min_x = w+1
	var min_y = h+1
	var max_x = -(w+1)
	var max_y = -(h+1)

	for delta_j in range(h):
		var negative_delta_j = h-delta_j-1
		for delta_i in range(w):
			var negative_delta_i = w-delta_i-1

			if delta_j < min_y and ca.matrix[delta_j][delta_i] == Constants.CA_Tiles.ALIVE:
				min_y = delta_j

			if negative_delta_j > max_y and ca.matrix[negative_delta_j][delta_i] == Constants.CA_Tiles.ALIVE:
				max_y = negative_delta_j

			if delta_i < min_x and ca.matrix[delta_j][delta_i] == Constants.CA_Tiles.ALIVE:
				min_x = delta_i

			if negative_delta_i > max_x and ca.matrix[delta_j][negative_delta_i] == Constants.CA_Tiles.ALIVE:
				max_x = negative_delta_i

	return [min_x, min_y, max_x, max_y]

func _to_string():
	var s = ("[CARoom] => " +
		"x1=" + str(x1()) + "; y1=" + str(y1()) + 
		"; x2=" + str(x2()) + "; y2=" + str(y2()) +
		"; w=" + str(width) + "; h=" + str(height)
	)

	return s

func _init(_ca, _x, _y, w, h):
	ca = _ca
	x = _x
	y = _y
	width = w
	height = h
