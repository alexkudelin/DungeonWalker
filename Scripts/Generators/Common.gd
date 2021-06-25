class_name CommonAlgos

var Constants = load("res://Scripts/Utils/Constants.gd")
var Utils = load("res://Scripts/Utils/Utils.gd")

var rng = null

func add_stuff(floor_grid, walls_grid, stuff_grid):
	var w = floor_grid[0].size()
	var h = floor_grid.size()

	var ignore = []

	for x in range(w):
		for y in range(h):
			if not ignore.has([x, y]):
				if floor_grid[y][x] == Constants.FloorTileCode.MID_FLOOR and walls_grid[y][x] == Constants.WallTileCode.EMPTY:
					var nb = Utils.get_moore_nb(walls_grid, x, y)
					var nc = Utils.count_objects_in_nb(nb, [Constants.WallTileCode.MID_WALL])

					if nc in [5, 6]:
						var p = rng.randf()

						if p > 0 and p <= 0.25:
							stuff_grid[y][x] = Constants.StuffTileCode.CHEST
						elif p > 0.25 and p <= 0.35:
							stuff_grid[y][x] = Constants.StuffTileCode.BIG_FLASK
						elif p > 0.35 and p <= 0.45:
							stuff_grid[y][x] = Constants.StuffTileCode.SMALL_FLASK
						else:
							continue

						for item in nb:
							ignore.append([item[0], item[1]])
					else:
						if rng.randf() <= 0.0075:
							stuff_grid[y][x] = Constants.StuffTileCode.CHEST
							for item in nb:
								ignore.append([item[0], item[1]])
							continue

						if rng.randf() <= 0.01:
							stuff_grid[y][x] = Constants.StuffTileCode.BIG_FLASK
							for item in nb:
								ignore.append([item[0], item[1]])
							continue

						if rng.randf() <= 0.01:
							stuff_grid[y][x] = Constants.StuffTileCode.SMALL_FLASK
							for item in nb:
								ignore.append([item[0], item[1]])
							continue


func _init(_rng=null):
	if _rng:
		rng = _rng
	else:
		rng = RandomNumberGenerator.new()
