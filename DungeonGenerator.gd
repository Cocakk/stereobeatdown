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
const ATLAS_NOVO_NIVEL = Vector2i(19, 1)
const PLAYER_SPAWN_TILE = Vector2i(30,30)
const ENEMY_SPAWN_TILE = Vector2i(26,37)

# Player e inimigos
var player_scene := preload("res://pastaplayer/player.tscn")
var inimigo1_scene := preload("res://geral/monster/mushroom.tscn")
var inimigo2_scene := preload("res://geral/monster/mafia.tscn")
var player = null

# Progressão de dungeon
var nivel_dungeon := 0
var enemy_spawn_points = []
var enemies_alive := 0
var limite := 26 # Limite total de inimigos mortos antes de emitir o sinal de porta
signal door

func _ready():
	randomize()
	gerar_nivel()

func gerar_nivel():
	nivel_dungeon += 1
	# Limpa tudo
	for child in get_children():
		if child != tilemap:
			child.queue_free()
	grid.clear()
	rooms.clear()
	enemy_spawn_points.clear()
	enemies_alive = 0

	initialize_grid()
	generate_rooms()
	connect_rooms()
	colocar_paredes_e_bordas()
	colocar_spawns()
	desenhar_no_tilemap()
	adicionar_player()
	spawn_inimigos()

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

func colocar_paredes_e_bordas():
	for y in range(1, grid_size.y - 2):
		for x in range(1, grid_size.x - 1):
			if grid[y+1][x] == TILE_CHAO and grid[y][x] == TILE_VAZIO:
				grid[y][x] = TILE_PAREDE
	for y in range(1, grid_size.y - 2):
		for x in range(1, grid_size.x - 1):
			if grid[y+1][x] == TILE_PAREDE and grid[y][x] == TILE_VAZIO:
				grid[y][x] = TILE_PAREDE2
	for y in range(1, grid_size.y - 1):
		for x in range(1, grid_size.x - 1):
			if grid[y][x] == TILE_VAZIO:
				var vizinhos = [
					grid[y-1][x], grid[y+1][x], grid[y][x-1], grid[y][x+1]
				]
				for v in vizinhos:
					if v != TILE_VAZIO:
						grid[y][x] = TILE_BORDA
						break

func colocar_spawns():
	enemy_spawn_points.clear()
	var salas_para_inimigos = []
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
			if room_tiles.size() > 0:
				var portal_tile = room_tiles.pop_front()
				grid[portal_tile.y][portal_tile.x] = TILE_NOVO_NIVEL
		else:
			salas_para_inimigos.append(room_tiles)

	# Progressão de inimigos por dungeon
	if nivel_dungeon == 1:
		# Só uma sala de inimigos: 4 mushrooms
		if salas_para_inimigos.size() > 0:
			var tiles = salas_para_inimigos[0]
			for j in range(min(4, tiles.size())):
				var enemy_tile = tiles[j]
				grid[enemy_tile.y][enemy_tile.x] = TILE_ENEMY_SPAWN
				enemy_spawn_points.append({"pos": enemy_tile, "tipo": "mushroom"})
	elif nivel_dungeon == 2:
		# Uma sala: 2 mushrooms, 2 mafias
		if salas_para_inimigos.size() > 0:
			var tiles = salas_para_inimigos[0]
			for j in range(min(2, tiles.size())):
				var enemy_tile = tiles[j]
				grid[enemy_tile.y][enemy_tile.x] = TILE_ENEMY_SPAWN
				enemy_spawn_points.append({"pos": enemy_tile, "tipo": "mushroom"})
			for j in range(2, min(4, tiles.size())):
				var enemy_tile = tiles[j]
				grid[enemy_tile.y][enemy_tile.x] = TILE_ENEMY_SPAWN
				enemy_spawn_points.append({"pos": enemy_tile, "tipo": "mafia"})
	elif nivel_dungeon >= 3:
		# Duas salas: uma só mafias, outra só mushrooms
		if salas_para_inimigos.size() > 0:
			var tiles = salas_para_inimigos[0]
			for j in range(min(4, tiles.size())):
				var enemy_tile = tiles[j]
				grid[enemy_tile.y][enemy_tile.x] = TILE_ENEMY_SPAWN
				enemy_spawn_points.append({"pos": enemy_tile, "tipo": "mafia"})
		if salas_para_inimigos.size() > 1:
			var tiles = salas_para_inimigos[1]
			for j in range(min(4, tiles.size())):
				var enemy_tile = tiles[j]
				grid[enemy_tile.y][enemy_tile.x] = TILE_ENEMY_SPAWN
				enemy_spawn_points.append({"pos": enemy_tile, "tipo": "mushroom"})

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
	if player and player.is_inside_tree():
		player.queue_free()
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			if grid[y][x] == TILE_PLAYER_SPAWN:
				player = player_scene.instantiate()
				player.position = tilemap.map_to_local(Vector2i(x, y))
				add_child(player)
				return

func spawn_inimigos():
	enemies_alive = 0
	for enemy_info in enemy_spawn_points:
		var inimigo
		if enemy_info["tipo"] == "mushroom":
			inimigo = inimigo1_scene.instantiate()
		else:
			inimigo = inimigo2_scene.instantiate()
		inimigo.position = tilemap.map_to_local(enemy_info["pos"])
		inimigo.player = player # Referência ao player
		inimigo.connect("morreu", Callable(self, "_on_enemy_died"))
		add_child(inimigo)
		enemies_alive += 1

func _on_enemy_died():
	enemies_alive -= 1
	limite -= 1
	if enemies_alive <= 0 and limite > 0:
		# Todos mortos, mas ainda não atingiu o limite, pode gerar novo nível ou abrir porta
		pass # Você pode colocar lógica extra aqui se quiser
	elif limite <= 0:
		emit_signal("door")

func _process(_delta):
	if player:
		var player_pos = tilemap.local_to_map(player.position)
		if player_pos.x >= 0 and player_pos.x < grid_size.x and player_pos.y >= 0 and player_pos.y < grid_size.y:
			if grid[player_pos.y][player_pos.x] == TILE_NOVO_NIVEL:
				gerar_nivel()
