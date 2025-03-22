extends Node2D

var nummortos : int = 0
@export var meta1 : int
@onready var animate = $AnimatedSprite2D
@onready var inimigo1 = preload("res://geral/monster/mushroom.tscn")
@onready var inimigo2 = preload("res://geral/monster/mafia.tscn")

func _ready():
	Morte.connect("morreu", Callable(self, "contagemdeinimigos"))
	randomize()

func contagemdeinimigos():
	nummortos += 1
	print("matooou ", nummortos)
	if nummortos == meta1:
		meta1 += 8
		spawn_inimigo()

func spawn_inimigo():
	var inimigo = randi_range(1, 3)
	var novo_inimigo

	if inimigo < 3:  # Se o número tirado for 1 ou 2, use o inimigo1
		novo_inimigo = inimigo1.instantiate()
		novo_inimigo.player = get_tree().get_first_node_in_group("player")
		print("Spawning inimigo1")
		novo_inimigo.face_left = false


	else:  # Se o número for 3, use o inimigo2
		novo_inimigo = inimigo2.instantiate()
		novo_inimigo.player = get_tree().get_first_node_in_group("player")
		print("Spawning inimigo2")
	add_child(novo_inimigo)
	novo_inimigo.attention = true
	novo_inimigo.player = get_tree().get_first_node_in_group("player")
	novo_inimigo.connect("morreu", Callable(playermanager, "_on_enemy_died"))
	novo_inimigo.connect("dano", Callable(playermanager, "_on_enemy_attack"))
	animate.play("default")
