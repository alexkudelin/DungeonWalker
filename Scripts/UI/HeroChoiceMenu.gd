extends Control

onready var hero_1 = $MarginContainer/VBoxContainer/WalkerControls/ChoiceHeroButton/HeroesBox/KnightBox/AnimatedSprite
onready var hero_2 = $MarginContainer/VBoxContainer/WalkerControls/ChoiceHeroButton/HeroesBox/WizardBox/AnimatedSprite
onready var hero_3 = $MarginContainer/VBoxContainer/WalkerControls/ChoiceHeroButton/HeroesBox/LizardBox/AnimatedSprite

onready var knight_selector = $MarginContainer/VBoxContainer/WalkerControls/ChoiceHeroButton/HeroesBox/KnightBox/Marker
onready var wizard_selector = $MarginContainer/VBoxContainer/WalkerControls/ChoiceHeroButton/HeroesBox/WizardBox/Marker
onready var lizard_selector = $MarginContainer/VBoxContainer/WalkerControls/ChoiceHeroButton/HeroesBox/LizardBox/Marker

onready var hero_marker = $MarginContainer/VBoxContainer/WalkerControls/ChoiceHeroButton/Marker
onready var start_game_marker = $MarginContainer/VBoxContainer/WalkerControls/StartButton/StartButton/Marker
onready var back_to_menu_marker = $MarginContainer/VBoxContainer/BackButton/BackButton/Marker

var menu_level = 0
var first_level_item = 0
var selected_hero = 0

func set_current_selection(_menu_level, _first_level_item, _selected_hero):
	hero_marker.text = ""
	start_game_marker.text = ""
	back_to_menu_marker.text = ""

	knight_selector.text = ""
	wizard_selector.text = ""
	lizard_selector.text = ""

	if _menu_level == 0:
		if _first_level_item == 0:
			hero_marker.text = ">"
		elif _first_level_item == 1:
			start_game_marker.text = ">"
		elif _first_level_item == 2:
			back_to_menu_marker.text = ">"

	if _selected_hero == 0:
		knight_selector.text = "*"
	elif _selected_hero == 1:
		wizard_selector.text = "*"
	elif _selected_hero == 2:
		lizard_selector.text = "*"


func _process(_delta):
	_handle_menu(menu_level)


func _handle_first_level_menu():
	if Input.is_action_just_pressed("ui_down") and first_level_item < 2:
		first_level_item += 1
		set_current_selection(menu_level, first_level_item, selected_hero)
	elif Input.is_action_just_pressed("ui_up") and first_level_item > 0:
		first_level_item -= 1
		set_current_selection(menu_level, first_level_item, selected_hero)
	# elif Input.is_action_just_pressed("ui_right"):
	# 	if first_level_item == 0:
	# 		menu_level += 1
	# 		set_current_selection(menu_level, first_level_item, selected_hero)
	elif Input.is_action_just_pressed("ui_accept"):
		_handle_accept()


func _handle_second_level_menu():
	if Input.is_action_just_pressed("ui_right") and selected_hero < 2:
		selected_hero += 1
		set_current_selection(menu_level, first_level_item, selected_hero)
	elif Input.is_action_just_pressed("ui_left") and selected_hero > 0:
		selected_hero -= 1
		set_current_selection(menu_level, first_level_item, selected_hero)
	# elif Input.is_action_just_pressed("ui_left"):
	# 	if first_level_item == 1:
	# 		menu_level -= 1
	# 		set_current_selection(menu_level, first_level_item, second_level_item, selected_hero)
	elif Input.is_action_just_pressed("ui_accept"):
		_handle_accept()


func _handle_menu(menu_lvl):
	if menu_lvl == 0:
		_handle_first_level_menu()
	elif menu_lvl == 1:
		_handle_second_level_menu()


func _handle_accept():
	if menu_level == 0:
		if first_level_item == 0:
			menu_level += 1
			set_current_selection(menu_level, first_level_item, selected_hero)
		elif first_level_item == 1:
			Global.hero = selected_hero
			get_tree().change_scene("res://Scenes/World.tscn")
		elif first_level_item == 2:
			get_tree().change_scene("res://Scenes/UI/GameSetupMenu.tscn")
	elif menu_level == 1:
		menu_level -= 1
		set_current_selection(menu_level, first_level_item, selected_hero)


func _ready():
	hero_1.play("idle")
	hero_2.play("idle")
	hero_3.play("idle")

	Global.hero = 0
	set_current_selection(0, 0, 0)
