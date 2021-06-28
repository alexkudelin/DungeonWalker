extends Node2D

var BSPNode = load("res://Scripts/BSP/BSPNode.gd")
var Room = load("res://Scripts/BSP/Room.gd")
var Hall = load("res://Scripts/BSP/Hall.gd")
var Constants = load("res://Scripts/Utils/Constants.gd")
var CellularAutomaton = load("res://Scripts/CA/CellularAutomaton.gd")

var BSP_Generator = load("res://Scripts/Generators/BSP.gd")
var CA_Generator = load("res://Scripts/Generators/CA.gd")
var BSP_CA_Generator = load("res://Scripts/Generators/BSP_CA_Hybrid.gd")

var TextureMaps = preload("res://Scripts/TextureMaps.gd").new()

var rng = RandomNumberGenerator.new()

var coins_collected = 0
var big_flasks_collected = 0
var small_flasks_collected = 0

const W = 64
const H = 64

onready var FLOOR = $Floor
onready var WALLS = $Walls
onready var STUFF = $Stuff
onready var PLAYER = $Player

const Chest = preload("res://Scenes/Chest/Chest.tscn")
const Coin = preload("res://Scenes/Coin/Coin.tscn")
const LevelExit = preload("res://Scenes/Exit/Exit.tscn")
const BigFlask = preload("res://Scenes/Flask/BigFlask/BigFlask.tscn")
const SmallFlask = preload("res://Scenes/Flask/SmallFlask/SmallFlask.tscn")

onready var coins_label = $ItemsCollected/Stats/Coins/CoinValue/Label
onready var big_flasks_label = $ItemsCollected/Stats/BigFlasks/BigFlaskValue/Label
onready var small_flasks_label = $ItemsCollected/Stats/SmallFlasks/SmallFlaskValue/Label

func _add_event_listeners():
	for area in get_tree().get_nodes_in_group("ChestAreas"):
		area.connect("body_entered", area, "OnChestAreaEntered")
		area.connect("body_exited", area, "OnChestAreaExited")

	for area in get_tree().get_nodes_in_group("CoinAreas"):
		area.connect("body_entered", area, "OnCoinAreaEntered")

	for area in get_tree().get_nodes_in_group("BigFlaskAreas"):
		area.connect("body_entered", area, "OnBigFlaskAreaEntered")
	
	for area in get_tree().get_nodes_in_group("SmallFlaskAreas"):
		area.connect("body_entered", area, "OnSmallFlaskAreaEntered")

	for area in get_tree().get_nodes_in_group("ExitArea"):
		area.connect("body_entered", area, "OnExitAreaEntered")
		area.connect("body_exited", area, "OnExitAreaExited")


func on_coin_collected(coin_node):
	coins_collected += 1
	coin_node.visible = false
	coins_label.text = str(coins_collected)


func on_big_flask_collected(big_flask_node):
	big_flasks_collected += 1
	big_flask_node.visible = false
	big_flasks_label.text = str(big_flasks_collected)


func on_small_flask_collected(small_flask_node):
	small_flasks_collected += 1
	small_flask_node.visible = false
	small_flasks_label.text = str(small_flasks_collected)


func _add_chest(x, y):
	var chest = Chest.instance()
	chest.set_position(STUFF.map_to_world(Vector2(x, y)))
	STUFF.add_child(chest)


func _add_coin(x, y):
	var coin = Coin.instance()
	coin.set_position(STUFF.map_to_world(Vector2(x, y)))
	STUFF.add_child(coin)


func _add_big_flask(x, y):
	var big_flask = BigFlask.instance()
	var stuff_textures = TextureMaps.StuffTextures[Constants.StuffTileCode.BIG_FLASK]
	var big_flask_sprite = Sprite.new()

	big_flask_sprite.texture = stuff_textures[rng.randi() % stuff_textures.size()]
	big_flask_sprite.offset = Vector2(8, 8)

	big_flask.add_child(big_flask_sprite)
	big_flask.set_position(STUFF.map_to_world(Vector2(x, y)))

	STUFF.add_child(big_flask)


func _add_small_flask(x, y):
	var small_flask = SmallFlask.instance()
	var stuff_textures = TextureMaps.StuffTextures[Constants.StuffTileCode.SMALL_FLASK]
	var small_flask_sprite = Sprite.new()

	small_flask_sprite.texture = stuff_textures[rng.randi() % stuff_textures.size()]
	small_flask_sprite.offset = Vector2(8, 8)

	small_flask.add_child(small_flask_sprite)
	small_flask.set_position(STUFF.map_to_world(Vector2(x, y)))

	STUFF.add_child(small_flask)


func _add_level_exit(x, y):
	var exit = LevelExit.instance()
	exit.set_position(STUFF.map_to_world(Vector2(x, y)))
	STUFF.add_child(exit)


func _add_stuff(level_stuff, x, y):
	var stuff_item = level_stuff[y][x]

	if stuff_item == Constants.StuffTileCode.CHEST:
		_add_chest(x, y)
	elif stuff_item == Constants.StuffTileCode.COIN:
		_add_coin(x, y)
	elif stuff_item == Constants.StuffTileCode.BIG_FLASK:
		_add_big_flask(x, y)
	elif stuff_item == Constants.StuffTileCode.SMALL_FLASK:
		_add_small_flask(x, y)
	elif stuff_item == Constants.StuffTileCode.LEVEL_EXIT:
		_add_level_exit(x, y)
	else:
		var stuff_texture = TextureMaps.StuffTextures[stuff_item]
		STUFF.set_cell(x, y, stuff_texture[0])


func _draw_dungeon(map):
	var level_floor = map["floor"]
	var level_walls = map["walls"]
	var level_stuff = map["stuff"]

	var w = len(level_floor[0])
	var h = len(level_floor)

	for x in range(w):
		for y in range(h):
			var floor_texture = TextureMaps.FloorTextures[level_floor[y][x]]
			var idx = 0

			if floor_texture.size() > 1:
				idx = rng.randi() % floor_texture.size()

			FLOOR.set_cell(x, y, floor_texture[idx])
			WALLS.set_cell(x, y, TextureMaps.WallTextures[level_walls[y][x]][0])
			
			_add_stuff(level_stuff, x, y)


func _clean(w, h):
	for i in range(-2*w, 2*w+1):
		for j in range(-2*h, 2*h+1):
			FLOOR.set_cell(i, j, TextureMaps.FloorTextures[Constants.FloorTileCode.EMPTY][0])
			WALLS.set_cell(i, j, TextureMaps.WallTextures[Constants.WallTileCode.EMPTY][0])
			STUFF.set_cell(i, j, TextureMaps.StuffTextures[Constants.StuffTileCode.EMPTY][0])


func _create_map():
	_clean(W, H)

	var cur_seed = Global._seed

	if cur_seed == null:
		rng.randomize()
		Global._seed = rng.seed
	else:
		rng.set_seed(cur_seed.hash())

	var gen = null

	if Global.selected_algorithm == 0:
		gen = BSP_Generator.new(rng)
	elif Global.selected_algorithm == 1:
		gen = CA_Generator.new(rng)
	elif Global.selected_algorithm == 2:
		gen = BSP_CA_Generator.new(rng)

	var map = gen.run(W, H)

	_draw_dungeon(map)

	PLAYER.position = FLOOR.map_to_world(Vector2(map.start[0], map.start[1]))

	_add_event_listeners()


func _process(_delta):
	if Input.is_action_just_pressed("recreate_map"):
		Global._seed = null
		_create_map()


func _ready():
	_create_map()
