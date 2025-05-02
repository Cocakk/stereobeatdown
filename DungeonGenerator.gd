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
const TILE_PAREDE2 = 6
const TILE_BORDA = 3
const TILE_PLAYER_SPAWN = 4
const TILE_ENEMY_SPAWN = 5
const TILE_NOVO_NIVEL = 7

# Configuração do atlas
const ATLAS_SOURCE = 0
const ATLAS_CHAO = [Vector2i(26, 36), Vector2i(18, 39), Vector2i(24, 31)]
const ATLAS_PAREDE = [Vector2i(27, 36), Vector2i(28, 36), Vector2i(29, 36)]
const ATLAS_PAREDE2 = [Vector2i(27, 36), Vector2i(28, 36), Vector2i(29, 36)]
const ATLAS_BORDA = Vector2i(28, 34)
const ATLAS_NOVO_NIVEL = Vector2i(19, 1) # Altere para o tile visual desejado
const PLAYER_SPAWN_TILE = Vector2i(30,30)
const ENEMY_SPAWN_TILE = Vector2i(26,37)

# Player e inimigos
var player_scene := preload("res://pastaplayer/player.tscn")
var inimigo_scene := preload("res://geral/monster/mushroom.tscn")
var player = null

func _ready():
	randomize()
	gerar_nivel()

func gerar_nivel():
	initialize_grid()
	generate_rooms()
	connect_rooms()
	colocar_paredes_e_bordas()
	colocar_spawns()
	desenhar_no_tilemap()
	adicionar_player()
	adicionar_inimigos()

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

# CORREDORES LARGOS (3 tiles)
func carve_horizontal_tunnel(x1, x2, y):
	for x in range(int(min(x1, x2)), int(max(x1, x2)) + 1):
		for dy in range(-1, 2):
			var ny = y + dy
			if ny >= 0 and ny < grid_size.y and x >= 0 and x < grid_size.x:
				grid[ny][x] = TILE_CHAO

func carve_vertical_tunnel(y1, y2, x):
	for y in range(int(min(y1, y2)), int(max(y1, y2)) + 1):
		for dx in range(-1, 2):
			var nx = x + dx
			if y >= 0 and y < grid_size.y and nx >= 0 and nx < grid_size.x:
				grid[y][nx] = TILE_CHAO

func generate_rooms():
	rooms.clear()
	for i in range(max_rooms):
		var w = randi_range(10, 20)
		var h = randi_range(10, 20)
		var pos = Vector2i(randi_range(2, grid_size.x - w - 3), randi_range(2, grid_size.y - h - 3))
		if not check_collision(pos, w, h):
			carve_room(pos, w, h)
			rooms.append({"pos": pos, "size": Vector2i(w, h)})

func connect_rooms():
	for i in range(1, rooms.size()):
		var prev_center = rooms[i-1].pos + rooms[i-1].size / 2
		var curr_center = rooms[i].pos + rooms[i].size / 2
		carve_horizontal_tunnel(int(prev_center.x), int(curr_center.x), int(prev_center.y))
		carve_vertical_tunnel(int(prev_center.y), int(curr_center.y), int(curr_center.x))

# PAREDES APENAS NO TOPO (DUAS CAMADAS) E BORDAS FINAS AO REDOR
func colocar_paredes_e_bordas():
	# Primeira linha de parede acima do chão/corredor
	for y in range(1, grid_size.y - 2):
		for x in range(1, grid_size.x - 1):
			if grid[y+1][x] == TILE_CHAO and grid[y][x] == TILE_VAZIO:
				grid[y][x] = TILE_PAREDE
	# Segunda linha de parede acima da primeira
	for y in range(1, grid_size.y - 2):
		for x in range(1, grid_size.x - 1):
			if grid[y+1][x] == TILE_PAREDE and grid[y][x] == TILE_VAZIO:
				grid[y][x] = TILE_PAREDE2

	# Bordas: só uma camada fina em volta de tudo
	for y in range(1, grid_size.y - 1):
		for x in range(1, grid_size.x - 1):
			if grid[y][x] == TILE_VAZIO:
				var vizinhos = [
					grid[y-1][x], # cima
					grid[y+1][x], # baixo
					grid[y][x-1], # esquerda
					grid[y][x+1]  # direita
				]
				for v in vizinhos:
					if v != TILE_VAZIO:
						grid[y][x] = TILE_BORDA
						break

# SPAWN DE PLAYER, INIMIGOS E PORTAL DE NOVO NÍVEL
func colocar_spawns():
	for i in range(rooms.size()):
		var sala = rooms[i]
		var pos = sala["pos"]
		var size = sala["size"]
		var room_tiles = []
		for y in range(pos.y, pos.y + size.y):
			for x in range(pos.x, pos.x + size.x):
				if grid[y][x] == TILE_CHAO:
					room_tiles.append(Vector2i(x, y))
		room_tiles.shuffle()
		if i == 0:
			if room_tiles.size() > 0:
				var player_tile = room_tiles.pop_front()
				grid[player_tile.y][player_tile.x] = TILE_PLAYER_SPAWN
		elif i == rooms.size() - 1:
			# Última sala recebe o portal/escada
			if room_tiles.size() > 0:
				var portal_tile = room_tiles.pop_front()
				grid[portal_tile.y][portal_tile.x] = TILE_NOVO_NIVEL
		else:
			for j in range(min(4, room_tiles.size())):
				var enemy_tile = room_tiles.pop_front()
				grid[enemy_tile.y][enemy_tile.x] = TILE_ENEMY_SPAWN

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
				TILE_PAREDE2:
					var idx = randi_range(0, ATLAS_PAREDE2.size() - 1)
					tilemap.set_cell(0, Vector2i(x, y), ATLAS_SOURCE, ATLAS_PAREDE2[idx])
				TILE_BORDA:
					tilemap.set_cell(0, Vector2i(x, y), ATLAS_SOURCE, ATLAS_BORDA)
				TILE_PLAYER_SPAWN:
					tilemap.set_cell(0, Vector2i(x, y), ATLAS_SOURCE, ATLAS_CHAO[0])
				TILE_ENEMY_SPAWN:
					tilemap.set_cell(0, Vector2i(x, y), ATLAS_SOURCE, ATLAS_CHAO[1])
				TILE_NOVO_NIVEL:
					tilemap.set_cell(0, Vector2i(x, y), ATLAS_SOURCE, ATLAS_NOVO_NIVEL)
				_:
					pass

func adicionar_player():
	# Remove player antigo se existir
	if player and player.is_inside_tree():
		player.queue_free()
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			if grid[y][x] == TILE_PLAYER_SPAWN:
				player = player_scene.instantiate()
				player.position = tilemap.map_to_local(Vector2i(x, y))
				add_child(player)
				return

func adicionar_inimigos():
	# Remove inimigos antigos se quiser, ou apenas limpe a cena antes de gerar novo nível
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			if grid[y][x] == TILE_ENEMY_SPAWN:
				var inimigo = inimigo_scene.instantiate()
				inimigo.position = tilemap.map_to_local(Vector2i(x, y))
				add_child(inimigo)

func _process(_delta):
	if player:
		var player_pos = tilemap.local_to_map(player.position)
		if player_pos.x >= 0 and player_pos.x < grid_size.x and player_pos.y >= 0 and player_pos.y < grid_size.y:
			if grid[player_pos.y][player_pos.x] == TILE_NOVO_NIVEL:
				gerar_nivel()
