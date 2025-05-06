extends Node2D

@onready var tilemap = $TileMap
@onready var canvas_layer = $CanvasLayer
@onready var label = $CanvasLayer/Label
@onready var music_player = $CanvasLayer/AudioStreamPlayer

var musicas = [
	preload("res://musicasdedungeon/8-bit-game-158815.mp3"),
	preload("res://musicasdedungeon/borboleta-neon-164517.mp3"),
	preload("res://musicasdedungeon/eles-estao-te-observando-181870.mp3"),
	preload("res://musicasdedungeon/espiritos-do-desespero-195665 (1).mp3"),
	preload("res://musicasdedungeon/um-vulto-no-beco-escuro-190396 (1).mp3")
]

var key = "beterruba"
var grid_size := Vector2i(50, 50)
var grid = []
var rooms = []

# Progressão e placar
var nivel_dungeon := 0
var rooms_vencidas := 0
var high_score := 0

# Parâmetros de dificuldade
var min_rooms := 3
var max_rooms := 4
var inimigos_base_por_sala := 2

# Limite de inimigos ativos
var limite := 8 # Ajuste conforme desejado

# Flags de controle
var pode_avancar := true
var portal_ativo := false

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

# Controle de inimigos
var enemy_spawn_points = []
var enemies_alive := 0
var enemies_queue = [] # fila de inimigos a serem instanciados

signal door

func _ready():
	randomize()
	tocar_musica_aleatoria()
	carregar_high_score()
	gerar_nivel()
	var config = ConfigFile.new()
	config.set_value("Scenes", "Name", get_tree().current_scene.scene_file_path)
	config.save_encrypted_pass("user://scenes.cfg", key)
	music_player.connect("finished", Callable(self, "_on_music_finished"))

func tocar_musica_aleatoria():
	var idx = randi_range(0, musicas.size() - 1)
	music_player.stream = musicas[idx]
	music_player.play()

func _on_music_finished():
	tocar_musica_aleatoria()

func gerar_nivel():
	pode_avancar = true
	portal_ativo = false
	nivel_dungeon += 1
	rooms_vencidas = nivel_dungeon - 1
	if rooms_vencidas > high_score:
		high_score = rooms_vencidas
		salvar_high_score()
	label.text = "Rooms vencidas: %d\nHigh Score: %d" % [rooms_vencidas, high_score]

	# Progressão de dificuldade (sempre inteiros!)
	min_rooms = max(3, 2 + int(nivel_dungeon * 0.3)) # Sempre pelo menos 3 salas!
	max_rooms = 4 + int(nivel_dungeon * 0.5)
	inimigos_base_por_sala = 2 + int(nivel_dungeon * 0.5)
	limite = 6 + int(nivel_dungeon * 0.4)

	# Limpa tudo, exceto tilemap e UI
	for child in get_children():
		if child != tilemap and child != canvas_layer:
			child.queue_free()
	grid.clear()
	rooms.clear()
	enemy_spawn_points.clear()
	enemies_alive = 0
	enemies_queue.clear()

	initialize_grid()
	generate_rooms()
	connect_rooms()
	colocar_paredes_e_bordas()
	colocar_spawns()
	desenhar_no_tilemap()
	adicionar_player()
	inicializar_fila_inimigos()
	spawn_inimigos_do_limite()

func salvar_high_score():
	var file = FileAccess.open("user://highscore.save", FileAccess.WRITE)
	file.store_32(high_score)
	file = null

func carregar_high_score():
	if FileAccess.file_exists("user://highscore.save"):
		var file = FileAccess.open("user://highscore.save", FileAccess.READ)
		high_score = file.get_32()
		file = null

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
	var tentativas = 0
	while rooms.size() < min_rooms or (rooms.size() < max_rooms and tentativas < max_rooms * 3):
		var w = randi_range(10, 16)
		var h = randi_range(10, 16)
		var pos = Vector2i(randi_range(2, grid_size.x - w - 3), randi_range(2, grid_size.y - h - 3))
		if not check_collision(pos, w, h):
			carve_room(pos, w, h)
			rooms.append({"pos": pos, "size": Vector2i(w, h)})
		tentativas += 1

func connect_rooms():
	if rooms.size() < 2:
		return
	# Sempre conecta as duas primeiras salas com pelo menos um corredor
	var first_center = rooms[0].pos + rooms[0].size / 2
	var second_center = rooms[1].pos + rooms[1].size / 2
	if randi() % 2 == 0:
		carve_horizontal_tunnel(int(first_center.x), int(second_center.x), int(first_center.y))
		carve_vertical_tunnel(int(first_center.y), int(second_center.y), int(second_center.x))
	else:
		carve_vertical_tunnel(int(first_center.y), int(second_center.y), int(first_center.x))
		carve_horizontal_tunnel(int(first_center.x), int(second_center.x), int(second_center.y))
	# Conecta as demais salas normalmente
	for i in range(2, rooms.size()):
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

	# Progressão: mais "mafia" conforme o nível
	var mafia_ratio = clamp(0.2 + float(nivel_dungeon) * 0.08, 0.2, 0.9)
	for idx in range(salas_para_inimigos.size()):
		var tiles = salas_para_inimigos[idx]
		var qtd_inimigos = min(inimigos_base_por_sala + int(nivel_dungeon * 0.5), tiles.size())
		for j in range(qtd_inimigos):
			var enemy_tile = tiles[j]
			grid[enemy_tile.y][enemy_tile.x] = TILE_ENEMY_SPAWN
			var tipo = "mafia" if randf() < mafia_ratio else "mushroom"
			enemy_spawn_points.append({"pos": enemy_tile, "tipo": tipo})

func inicializar_fila_inimigos():
	enemies_queue.clear()
	for enemy_info in enemy_spawn_points:
		enemies_queue.append(enemy_info)

func spawn_inimigos_do_limite():
	while enemies_alive < limite and enemies_queue.size() > 0:
		var enemy_info = enemies_queue.pop_front()
		var inimigo
		if enemy_info["tipo"] == "mushroom":
			inimigo = inimigo1_scene.instantiate()
		else:
			inimigo = inimigo2_scene.instantiate()
		inimigo.position = tilemap.map_to_local(enemy_info["pos"])
		inimigo.player = player
		inimigo.connect("morreu", Callable(self, "_on_enemy_died"))
		add_child(inimigo)
		enemies_alive += 1

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

func _on_enemy_died():
	enemies_alive -= 1
	if enemies_queue.size() > 0:
		spawn_inimigos_do_limite()
	elif enemies_alive == 0:
		portal_ativo = true # Agora o portal pode ser usado

func _process(_delta):
	if player:
		var player_pos = tilemap.local_to_map(player.position)
		if player_pos.x >= 0 and player_pos.x < grid_size.x and player_pos.y >= 0 and player_pos.y < grid_size.y:
			if grid[player_pos.y][player_pos.x] == TILE_NOVO_NIVEL and portal_ativo:
				if pode_avancar:
					pode_avancar = false
					gerar_nivel()
			elif grid[player_pos.y][player_pos.x] != TILE_NOVO_NIVEL:
				pode_avancar = true
