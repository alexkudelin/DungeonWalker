extends MarginContainer

onready var seed_input_marker = $CenterContainer/VBoxContainer/Buttons/ButtonsVBox/SeedInput/SeedTextLabels/SeedInputMarker
onready var seed_input = $CenterContainer/VBoxContainer/Buttons/ButtonsVBox/SeedInput/SeedTextLabels/SeedInput

onready var algo_selector_marker = $CenterContainer/VBoxContainer/Buttons/ButtonsVBox/AlgorithmSelector/AlgorithmSelector/AlgorithmSelectorMarker
onready var bsp_marker = $CenterContainer/VBoxContainer/Buttons/ButtonsVBox/AlgorithmSelector/AlgorithmSelector/AlgorithmList/AlgorithmList/BSP_Item/HBoxContainer/BSP_ItemMarker
onready var ca_marker = $CenterContainer/VBoxContainer/Buttons/ButtonsVBox/AlgorithmSelector/AlgorithmSelector/AlgorithmList/AlgorithmList/CA_Item/HBoxContainer/CA_ItemMarker
onready var bsp_ca_marker = $CenterContainer/VBoxContainer/Buttons/ButtonsVBox/AlgorithmSelector/AlgorithmSelector/AlgorithmList/AlgorithmList/BSP_CA_Item/HBoxContainer/BSP_CA_ItemMarker

onready var start_game_item = $CenterContainer/VBoxContainer/Buttons/ButtonsVBox/PlayButton/PlayButtonLabels/PlayButtonMarker
onready var back_to_menu_item = $CenterContainer/VBoxContainer/Buttons/ButtonsVBox/BackButton/BackButtonLabels/BackButtonMarker

var menu_level = 0
var first_level_item = 0
var second_level_item = 0

func set_current_selection(_menu_level, _first_level_item, _second_level_item):
	seed_input_marker.text = ""
	algo_selector_marker.text = ""
	bsp_marker.text = ""
	ca_marker.text = ""
	bsp_ca_marker.text = "*"
	start_game_item.text = ""
	back_to_menu_item.text = ""
	
	if _menu_level == 0:
		if _first_level_item == 0:
			seed_input_marker.text = ">"
		elif _first_level_item == 1:
			algo_selector_marker.text = ">"
		elif _first_level_item == 2:
			start_game_item.text = ">"
		elif _first_level_item == 3:
			back_to_menu_item.text = ">"
	elif _menu_level == 1:
		if _second_level_item == 0:
			bsp_marker.text = "*"
		elif _second_level_item == 1:
			ca_marker.text = "*"
		elif _second_level_item == 2:
			bsp_ca_marker.text = "*"


func _process(delta):
	_handle_menu(menu_level)


func _handle_first_level_menu():
	if Input.is_action_just_pressed("ui_down") and first_level_item < 3:
		first_level_item += 1
		set_current_selection(menu_level, first_level_item, second_level_item)
	elif Input.is_action_just_pressed("ui_up") and first_level_item > 0:
		first_level_item -= 1
		set_current_selection(menu_level, first_level_item, second_level_item)
	elif Input.is_action_just_pressed("ui_right"):
		if first_level_item == 0:
			menu_level += 1
			seed_input.grab_focus()
		elif first_level_item == 1:
			menu_level += 1
			set_current_selection(menu_level, first_level_item, second_level_item)
	elif Input.is_action_just_pressed("ui_accept"):
		_handle_accept()


func _handle_second_level_menu():
	if Input.is_action_just_pressed("ui_down") and second_level_item < 2:
		second_level_item += 1
		set_current_selection(menu_level, first_level_item, second_level_item)
	elif Input.is_action_just_pressed("ui_up") and second_level_item > 0:
		second_level_item -= 1
		set_current_selection(menu_level, first_level_item, second_level_item)
	elif Input.is_action_just_pressed("ui_left"):
		menu_level -= 1
		set_current_selection(menu_level, first_level_item, second_level_item)


func _handle_menu(menu_lvl):
	if menu_lvl == 0:
		_handle_first_level_menu()
	elif menu_lvl == 1:
		_handle_second_level_menu()


func _handle_accept():
	if first_level_item == 2:
		print("start")
	elif first_level_item == 3:
		print("back")


func _ready():
	set_current_selection(0, 0, 2)
