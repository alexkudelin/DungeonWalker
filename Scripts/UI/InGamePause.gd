extends CanvasLayer

onready var conitnue_marker = $MarginContainer/VBoxContainer/GeneratorControls/VBoxContainer/CenterContainer/ContinueButton/ContinueButton/Marker
onready var return_to_menu_marker = $MarginContainer/VBoxContainer/GeneratorControls/VBoxContainer/CenterContainer/ReturnToMenuButton/ReturnToMenuButton/Marker
onready var return_to_desktop_marker = $MarginContainer/VBoxContainer/GeneratorControls/VBoxContainer/CenterContainer/ReturnToDesktopButton/ReturnToDesktopButton/Marker
onready var seed_label = $MarginContainer/VBoxContainer/GeneratorControls/VBoxContainer/SeedLabel/Label

var current_item = 0

func _ready():
	set_visibility(false)
	set_current_selection(0)


func _toggle_pause():
	get_tree().paused = !get_tree().paused
	set_visibility(get_tree().paused)


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		_toggle_pause()
		seed_label.text = str(Global._seed)


func set_visibility(state):
	for child in get_children():
		child.visible = state


func set_current_selection(_current_item):
	conitnue_marker.text = ""
	return_to_menu_marker.text = ""
	return_to_desktop_marker.text = ""

	if _current_item == 0:
		conitnue_marker.text = ">"
	elif _current_item == 1:
		return_to_menu_marker.text = ">"
	elif _current_item == 2:
		return_to_desktop_marker.text = ">"


func _process(_delta):
	if get_tree().paused:
		if Input.is_action_just_pressed("ui_down") and current_item < 2:
			current_item += 1
			set_current_selection(current_item)
		elif Input.is_action_just_pressed("ui_up") and current_item > 0:
			current_item -= 1
			set_current_selection(current_item)
		elif Input.is_action_just_pressed("ui_accept"):
			_handle_selection()


func _handle_selection():
	if current_item == 0:
		_toggle_pause()
	elif current_item == 1:
		get_tree().paused = false
		set_visibility(false)
		get_tree().change_scene("res://Scenes/UI/GameSetupMenu.tscn")
	elif current_item == 2:
		get_tree().paused = false
		set_visibility(false)
		get_tree().quit(0)
