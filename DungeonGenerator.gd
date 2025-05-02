extends Node2D
@onready var tilemap = $TileMap

var grid_size := Vector2i(50, 50)
var max_rooms := 10
var grid = []
var rooms = []

# Tipos de tiles no grid
const TILE_VAZIO = 0
const TILE_CHAO = 1
const TILE_PAREDE = 2
const TILE_BORDA = 3

# Configuração do atlas (ajuste conforme seu TileSet)
const ATLAS_SOURCE = 0
const ATLAS_CHAO = [Vector2i(26, 36), Vector2i(18, 39), Vector2i(24, 31)]
const ATLAS_PAREDE = [Vector2i(27, 36), Vector2i(28, 36), Vector2i(29, 36)]
const ATLAS_BORDA = Vector2i(28, 34)

func _ready():
	randomize()
	initialize_grid()
	generate_rooms()
	connect_rooms()
	colocar_paredes_e_bordas()
	desenhar_no_tilemap()

func initialize_grid():
	grid = []
	for y in range(grid_size.y):
		grid.append([])
		for x in range(grid_size.x):
			grid[y].append(TILE_VAZIO)

func check_collision(pos, w, h):
	for y in range(int(pos.y) - 2, int(pos.y) + h + 2):
		for x in range(int(pos.x) - 2, int(pos.x) + w + 2):
			if y >= 0 and y < grid_size.y and x >= 0 and x < grid_size.x:
				if grid[y][x] != TILE_VAZIO:
					return true
	return false

func carve_room(pos, w, h):
	for y in range(int(pos.y), int(pos.y) + h):
		for x in range(int(pos.x), int(pos.x) + w):
			grid[y][x] = TILE_CHAO

func generate_rooms():
	for i in range(max_rooms):
		var w = randi_range(4, 8)
		var h = randi_range(4, 8)
		var pos = Vector2i(randi_range(2, grid_size.x - w - 3), randi_range(2, grid_size.y - h - 3))
		if not check_collision(pos, w, h):
			carve_room(pos, w, h)
			rooms.append({"pos": pos, "size": Vector2i(w, h)})

func carve_horizontal_tunnel(x1, x2, y):
	for x in range(int(min(x1, x2)), int(max(x1, x2)) + 1):
		if y >= 0 and y < grid_size.y and x >= 0 and x < grid_size.x:
			grid[y][x] = TILE_CHAO

func carve_vertical_tunnel(y1, y2, x):
	for y in range(int(min(y1, y2)), int(max(y1, y2)) + 1):
		if y >= 0 and y < grid_size.y and x >= 0 and x < grid_size.x:
			grid[y][x] = TILE_CHAO

func connect_rooms():
	for i in range(1, rooms.size()):
		var prev_center = rooms[i-1].pos + rooms[i-1].size / 2
		var curr_center = rooms[i].pos + rooms[i].size / 2
		carve_horizontal_tunnel(int(prev_center.x), int(curr_center.x), int(prev_center.y))
		carve_vertical_tunnel(int(prev_center.y), int(curr_center.y), int(curr_center.x))

func colocar_paredes_e_bordas():
	for y in range(1, grid_size.y - 1):
		for x in range(1, grid_size.x - 1):
			# Se for chão e o tile acima for vazio, coloque parede acima
			if grid[y][x] == TILE_CHAO and grid[y-1][x] == TILE_VAZIO:
				grid[y-1][x] = TILE_PAREDE
	# Agora coloque borda em volta de tudo que não for vazio
	for y in range(1, grid_size.y - 1):
		for x in range(1, grid_size.x - 1):
			if grid[y][x] in [TILE_CHAO, TILE_PAREDE]:
				# Acima
				if grid[y-1][x] == TILE_VAZIO:
					grid[y-1][x] = TILE_BORDA
				# Abaixo
				if grid[y+1][x] == TILE_VAZIO:
					grid[y+1][x] = TILE_BORDA
				# Esquerda
				if grid[y][x-1] == TILE_VAZIO:
					grid[y][x-1] = TILE_BORDA
				# Direita
				if grid[y][x+1] == TILE_VAZIO:
					grid[y][x+1] = TILE_BORDA

func desenhar_no_tilemap():
	tilemap.clear()
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			match grid[y][x]:
				TILE_CHAO:
					var idx = randi_range(0, ATLAS_CHAO.size() - 1)
					tilemap.set_cell(0, Vector2i(x, y), ATLAS_SOURCE, ATLAS_CHAO[idx])
				TILE_PAREDE:
					var idx = randi_range(0, ATLAS_PAREDE.size() - 1)
					tilemap.set_cell(0, Vector2i(x, y), ATLAS_SOURCE, ATLAS_PAREDE[idx])
				TILE_BORDA:
					tilemap.set_cell(0, Vector2i(x, y), ATLAS_SOURCE, ATLAS_BORDA)
				_:
					pass # vazio não desenha nada
