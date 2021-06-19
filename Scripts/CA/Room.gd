class_name CARoom

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
