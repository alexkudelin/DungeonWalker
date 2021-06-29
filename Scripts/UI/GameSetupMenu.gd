extends Control

onready var seed_marker = $MarginContainer/VBoxContainer/GeneratorControls/SeedInput/SeedInput/Marker
onready var algo_list_marker = $MarginContainer/VBoxContainer/GeneratorControls/AlgorithmsList/AlgorithmsList/Marker
onready var start_game_marker = $MarginContainer/VBoxContainer/GeneratorControls/StartButton/StartButton/Marker
onready var back_to_menu_marker = $MarginContainer/VBoxContainer/BackButton/BackButton/Marker

onready var bsp_marker = $MarginContainer/VBoxContainer/GeneratorControls/AlgorithmsList/AlgorithmsList/AlgorithmsList/AlgorithmsList/BSP/Marker
onready var ca_marker = $MarginContainer/VBoxContainer/GeneratorControls/AlgorithmsList/AlgorithmsList/AlgorithmsList/AlgorithmsList/CA/Marker
onready var bsp_ca_marker = $MarginContainer/VBoxContainer/GeneratorControls/AlgorithmsList/AlgorithmsList/AlgorithmsList/AlgorithmsList/BSP_CA/Marker

onready var bsp_selector = $MarginContainer/VBoxContainer/GeneratorControls/AlgorithmsList/AlgorithmsList/AlgorithmsList/AlgorithmsList/BSP/Selector
onready var ca_selector = $MarginContainer/VBoxContainer/GeneratorControls/AlgorithmsList/AlgorithmsList/AlgorithmsList/AlgorithmsList/CA/Selector
onready var bsp_ca_selector = $MarginContainer/VBoxContainer/GeneratorControls/AlgorithmsList/AlgorithmsList/AlgorithmsList/AlgorithmsList/BSP_CA/Selector

onready var seed_input = $MarginContainer/VBoxContainer/GeneratorControls/SeedInput/SeedInput/SeedInput/Input

var menu_level = 0
var first_level_item = 0
var second_level_item = 0
var selected_algo = 2

func set_current_selection(_menu_level, _first_level_item, _second_level_item, _selected_algo):
	seed_marker.text = ""
	algo_list_marker.text = ""
	start_game_marker.text = ""
	back_to_menu_marker.text = ""

	bsp_marker.text = ""
	ca_marker.text = ""
	bsp_ca_marker.text = ""

	bsp_selector.text = ""
	ca_selector.text = ""
	bsp_ca_selector.text = ""

	if _menu_level == 0:
		if _first_level_item == 0:
			seed_marker.text = ">"
		elif _first_level_item == 1:
			algo_list_marker.text = ">"
		elif _first_level_item == 2:
			start_game_marker.text = ">"
		elif _first_level_item == 3:
			back_to_menu_marker.text = ">"
	elif _menu_level == 1:
		if _second_level_item == 0:
			bsp_marker.text = ">"
		elif _second_level_item == 1:
			ca_marker.text = ">"
		elif _second_level_item == 2:
			bsp_ca_marker.text = ">"

	if _selected_algo == 0:
		bsp_selector.text = "*"
	elif _selected_algo == 1:
		ca_selector.text = "*"
	elif _selected_algo == 2:
		bsp_ca_selector.text = "*"


func _process(_delta):
	_handle_menu(menu_level)


func _handle_first_level_menu():
	if Input.is_action_just_pressed("ui_down") and first_level_item < 3:
		first_level_item += 1
		set_current_selection(menu_level, first_level_item, second_level_item, selected_algo)
	elif Input.is_action_just_pressed("ui_up") and first_level_item > 0:
		first_level_item -= 1
		set_current_selection(menu_level, first_level_item, second_level_item, selected_algo)
	elif Input.is_action_just_pressed("ui_right"):
		if first_level_item == 1:
			menu_level += 1
			set_current_selection(menu_level, first_level_item, second_level_item, selected_algo)
	elif Input.is_action_just_pressed("ui_accept"):
		_handle_accept()


func _handle_second_level_menu():
	if Input.is_action_just_pressed("ui_down") and second_level_item < 2:
		if first_level_item == 1:
			second_level_item += 1
			set_current_selection(menu_level, first_level_item, second_level_item, selected_algo)
	elif Input.is_action_just_pressed("ui_up") and second_level_item > 0:
		if first_level_item == 1:
			second_level_item -= 1
			set_current_selection(menu_level, first_level_item, second_level_item, selected_algo)
	elif Input.is_action_just_pressed("ui_left"):
		if first_level_item == 1:
			menu_level -= 1
			set_current_selection(menu_level, first_level_item, second_level_item, selected_algo)
	elif Input.is_action_just_pressed("ui_accept"):
		_handle_accept()


func _handle_menu(menu_lvl):
	if menu_lvl == 0:
		_handle_first_level_menu()
	elif menu_lvl == 1:
		_handle_second_level_menu()


func _handle_accept():
	if first_level_item == 0:
		if menu_level == 0:
			seed_input.grab_focus()
		elif menu_level == 1:
			seed_input.release_focus()
			seed_marker.grab_focus()
		set_current_selection(menu_level, first_level_item, second_level_item, selected_algo)
	elif first_level_item == 1:
		if menu_level == 0:
			if first_level_item == 1:
				menu_level += 1
				set_current_selection(menu_level, first_level_item, second_level_item, selected_algo)
		elif menu_level == 1:
			selected_algo = second_level_item
			set_current_selection(menu_level, first_level_item, second_level_item, selected_algo)
	elif first_level_item == 2:
		Global.selected_algorithm = selected_algo
		get_tree().change_scene("res://Scenes/World.tscn")
	elif first_level_item == 3:
		get_tree().change_scene("res://Scenes/UI/MainMenu.tscn")


func _ready():
	Global._seed = null
	set_current_selection(0, 0, 2, 2)


func _on_seed_changed(new_text: String):
	Global._seed = new_text
