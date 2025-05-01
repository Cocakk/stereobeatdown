extends Node2D

var grid_size := Vector2(50, 50)
var cell_size := 16
var max_rooms := 10
var grid = []
var rooms = []

func _ready():
	randomize()
	initialize_grid()
	generate_rooms()
	connect_rooms()
	draw_dungeon()

func initialize_grid():
	grid = []
	for y in range(grid_size.y):
		grid.append([])
		for x in range(grid_size.x):
			grid[y].append(1) # 1 = parede

func check_collision(pos, w, h):
	for y in range(pos.y - 1, pos.y + h + 1):
		for x in range(pos.x - 1, pos.x + w + 1):
			if y >= 0 and y < grid_size.y and x >= 0 and x < grid_size.x:
				if grid[y][x] == 0:
					return true
	return false

func carve_room(pos, w, h):
	for y in range(pos.y, pos.y + h):
		for x in range(pos.x, pos.x + w):
			grid[y][x] = 0 # 0 = piso

func generate_rooms():
	for i in range(max_rooms):
		var w = randi_range(4, 8)
		var h = randi_range(4, 8)
		var pos = Vector2(randi_range(0, grid_size.x - w - 1), randi_range(0, grid_size.y - h - 1))
		if not check_collision(pos, w, h):
			carve_room(pos, w, h)
			rooms.append({"pos": pos, "size": Vector2(w, h)})

func carve_horizontal_tunnel(x1, x2, y):
	for x in range(int(min(x1, x2)), int(max(x1, x2)) + 1):
		if y >= 0 and y < grid_size.y and x >= 0 and x < grid_size.x:
			grid[y][x] = 0

func carve_vertical_tunnel(y1, y2, x):
	for y in range(int(min(y1, y2)), int(max(y1, y2)) + 1):
		if y >= 0 and y < grid_size.y and x >= 0 and x < grid_size.x:
			grid[y][x] = 0

func connect_rooms():
	for i in range(1, rooms.size()):
		var prev_center = rooms[i-1].pos + rooms[i-1].size / 2
		var curr_center = rooms[i].pos + rooms[i].size / 2
		carve_horizontal_tunnel(prev_center.x, curr_center.x, prev_center.y)
		carve_vertical_tunnel(prev_center.y, curr_center.y, curr_center.x)

func draw_dungeon():
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var rect = ColorRect.new()
			rect.color = Color.BLACK if grid[y][x] == 1 else Color.WHITE
			rect.size = Vector2(cell_size, cell_size)
			rect.position = Vector2(x * cell_size, y * cell_size)
			add_child(rect)
