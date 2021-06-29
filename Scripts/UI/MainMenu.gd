extends MarginContainer

onready var start_item = $MarginContainer/VBoxContainer/GeneratorControls/VBoxContainer/StartButton/StartButton/Marker
onready var exit_item = $MarginContainer/VBoxContainer/GeneratorControls/VBoxContainer/ExitButton/ExitButton/Marker

var current_item = 0

func set_current_selection(_cur_sel):
	start_item.text = ""
	exit_item.text = ""

	if _cur_sel == 0:
		start_item.text = ">"
	elif _cur_sel == 1:
		exit_item.text = ">"

func _process(_delta):
	if Input.is_action_just_pressed("ui_down") and current_item < 1:
		current_item += 1
		set_current_selection(current_item)
	elif Input.is_action_just_pressed("ui_up") and current_item > 0:
		current_item -= 1
		set_current_selection(current_item)
	elif Input.is_action_just_pressed("ui_accept"):
		_handle_selection()


func _handle_selection():
	if current_item == 0:
		get_tree().change_scene("res://Scenes/UI/GameSetupMenu.tscn")
	elif current_item == 1:
		get_tree().quit(0)


func _ready():
	set_current_selection(0)
