extends CanvasLayer

onready var timer = $HBoxContainer/Time
var time = 0

func _process(delta):
	time += delta
	time = stepify(time, 0.01)

	var minutes = int(time) / 60
	var seconds = int(time) % 60

	timer.text = ("%02d" % minutes) + ":" + ("%02d" % seconds) + "." + str(int((time - minutes*60 - seconds)*100))

func get_time():
	return time
