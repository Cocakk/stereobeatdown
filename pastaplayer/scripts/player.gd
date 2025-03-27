class_name Player extends CharacterBody2D

var tiro = -1
var cardinal_direction : Vector2 = Vector2.DOWN
var direction : Vector2 = Vector2.ZERO
const DIR_4 = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]
@onready var state_machine : Player_StateMachine = $StateMachine

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $Sprite2D
signal vencivel
signal playermorreu
var invencivel = false
@onready var timer = $Timer
var morto = false
signal morreu
signal DirectionChanged(new_direction : Vector2)
signal pericles
	
	
	
func _ready():
	state_machine.initialize(self)
	add_to_group("player")
	
	#inimigos comuns:
	for enemy in get_tree().get_nodes_in_group("inimigos"):
		enemy.connect("morreu", Callable(self, "oinimigomorreu"))
	for enemy in get_tree().get_nodes_in_group("inimigos"):
		enemy.connect("dano", Callable(self, "levodano"))
	for bullet in get_tree().get_nodes_in_group("bullets"):
		bullet.connect("Bala", Callable(self, "levotiro"))
	for explosion in get_tree().get_nodes_in_group("explosivo"):
		explosion.connect("explosion", Callable(self, "levotiro"))
	

func _process(_delta):
	direction = Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	).normalized()

func _physics_process(_delta):
	move_and_slide()

func _SetDirection() -> bool:
	if morto != true:
		if direction == Vector2.ZERO:
			return false

		var direction_id : int = int(round((direction + cardinal_direction * 0.1).angle() / TAU * DIR_4.size()))
		var newdir = DIR_4 [direction_id]
		if newdir == cardinal_direction:
			return false 
		cardinal_direction = newdir
		DirectionChanged.emit(newdir)
		sprite.scale.x = -1 if cardinal_direction == Vector2.LEFT else 1
		
	return true 
	
func levotiro():
	##o player tem que morrer assim que levar o tiro, sua invencibilidade não serve para balas.
	print("player levou tiro")

	if tiro == 1:
		if direction.y <= 0 and !morto:
			animation_player.play("morte_up")
		elif direction.y >= 0 and !morto:
			animation_player.play("morte_down")
		morto = true
		emit_signal("morreu")
		emit_signal("playermorreu")
	else: 
		tiro += 1
	
func _UpdateAnimation ( state : String ) -> void:
	if morto != true:
		animation_player.play(state + "_" + AnimDirection())

func AnimDirection () -> String:
	if cardinal_direction == Vector2.DOWN:
		return ("down")
	elif cardinal_direction == Vector2.UP:
		return ("up")
	else:
		return ("side")

func oinimigomorreu():
	timer.start()
	emit_signal("pericles")
	invencivel = true
	print("o player recebe o sinal de morte")
	return

func levodano():
	var danorecebido = 0
	if invencivel:
		print("nem senti sifodakkk")
	else:
		print("recebi dano")
		if direction.y <= 0 and !morto:
			animation_player.play("morte_up")
		elif direction.y >= 0 and !morto:
			animation_player.play("morte_down")
		morto = true
		emit_signal("morreu")
		emit_signal("playermorreu")

func _on_timer_timeout():
	emit_signal("vencivel")
	invencivel = false
	print("o timer funciona perfeitamente") 
	timer.stop()

func _on_attack_reload():
	# Implementação pendente
	pass

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "morte_up" or anim_name == "morte_down":
		get_tree().change_scene_to_file("res://deathscene.tscn")

func _on_drink_bebi():
	
	timer.start()
	invencivel = true

# Função para receber dano (pode ser chamada pela bala)
func take_damage(damage):
	if not invencivel:
		levodano()  # Usa a função existente para processar o dano
