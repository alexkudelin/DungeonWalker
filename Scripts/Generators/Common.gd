class_name CommonAlgos

var Constants = load("res://Scripts/Utils/Constants.gd")
var Utils = load("res://Scripts/Utils/Utils.gd")

var rng = null

var stuff_list = [
	Constants.StuffTileCode.CHEST,
	Constants.StuffTileCode.BIG_FLASK,
	Constants.StuffTileCode.SMALL_FLASK,
	Constants.StuffTileCode.COIN,
]

func _check_neighbourhood(nb, nc):
	var empty = Constants.WallTileCode.EMPTY

	if nc == 7:
		return (nb[1][2] == empty or nb[3][2] == empty or nb[4][2] == empty or nb[7][2] == empty)
	elif nc == 6:
		return (
			(nb[1][2] == empty and nb[2][2] == empty) or
			(nb[4][2] == empty and nb[7][2] == empty) or
			(nb[5][2] == empty and nb[6][2] == empty) or
			(nb[0][2] == empty and nb[3][2] == empty) or
			(nb[0][2] == empty and nb[1][2] == empty) or
			(nb[2][2] == empty and nb[4][2] == empty) or
			(nb[6][2] == empty and nb[7][2] == empty) or
			(nb[3][2] == empty and nb[5][2] == empty)
		)
	elif nc == 5:
		return (
			(
				(nb[0][2] == empty and nb[1][2] == empty and nb[2][2] == empty) or
				(nb[2][2] == empty and nb[4][2] == empty and nb[7][2] == empty) or
				(nb[7][2] == empty and nb[6][2] == empty and nb[5][2] == empty) or
				(nb[5][2] == empty and nb[3][2] == empty and nb[0][2] == empty)
			) or (
				(nb[5][2] == empty and nb[3][2] == empty and nb[0][2] == empty and nb[1][2] == empty and nb[2][2] == empty) or
				(nb[0][2] == empty and nb[1][2] == empty and nb[2][2] == empty and nb[4][2] == empty and nb[7][2] == empty) or
				(nb[2][2] == empty and nb[4][2] == empty and nb[7][2] == empty and nb[6][2] == empty and nb[5][2] == empty) or
				(nb[7][2] == empty and nb[6][2] == empty and nb[5][2] == empty and nb[3][2] == empty and nb[0][2] == empty)
			)
		)
	elif nc == 4:
		return (
			(nb[0][2] == empty and nb[1][2] == empty and nb[2][2] == empty and nb[4][2] == empty) or
			(nb[1][2] == empty and nb[2][2] == empty and nb[4][2] == empty and nb[7][2] == empty) or
			(nb[2][2] == empty and nb[4][2] == empty and nb[7][2] == empty and nb[6][2] == empty) or
			(nb[4][2] == empty and nb[7][2] == empty and nb[6][2] == empty and nb[5][2] == empty) or
			(nb[7][2] == empty and nb[6][2] == empty and nb[5][2] == empty and nb[3][2] == empty) or
			(nb[6][2] == empty and nb[5][2] == empty and nb[3][2] == empty and nb[0][2] == empty) or
			(nb[5][2] == empty and nb[3][2] == empty and nb[0][2] == empty and nb[1][2] == empty) or
			(nb[3][2] == empty and nb[0][2] == empty and nb[1][2] == empty and nb[2][2] == empty)
		)


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

					if nc in [5, 6, 7]:
						if _check_neighbourhood(nb, nc):
							if rng.randf() < 0.66:
								stuff_grid[y][x] = stuff_list[rng.randi() % stuff_list.size()]

							for item in nb:
								ignore.append([item[0], item[1]])
					elif nc == 0:
						var p = rng.randf()

						if p <= 0.0375:
							var skip = false

							for item in nb:
								if ignore.has([item[0], item[1]]):
									skip = true
									break

							if not skip:
								stuff_grid[y][x] = Constants.StuffTileCode.CHEST
						elif 0.0375 < p and p <= 0.0875:
							stuff_grid[y][x] = Constants.StuffTileCode.BIG_FLASK
						elif 0.0875 < p and p <= 0.1375:
							stuff_grid[y][x] = Constants.StuffTileCode.SMALL_FLASK
						else:
							continue

						for item in nb:
							ignore.append([item[0], item[1]])


func _init(_rng=null):
	if _rng:
		rng = _rng
	else:
		rng = RandomNumberGenerator.new()
