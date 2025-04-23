extends CharacterBody2D

### Variáveis e Conexões
@export var face_left: bool = true
@onready var anini = $AnimatedSprite2D
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@onready var detection_area = $Area2D
@onready var detectionshape = $Area2D/CollisionShape2D
@onready var timer_2 = $Timer2
@export var attention = true
var sangue = preload("res://sangue.tscn")
signal morreu
signal dano


var playermorto = false

@export var speed = 120
@export var player : Node2D
var damagetaken = 0
var state = "idle"
var podebate = false
var player_in_range = false
var attackcooldown = false
var can_detect_player = false  # Nova variável para controlar a detecção do jogador

### Funções de Inicialização
func _ready():
	z_index = 1
	nav_agent.avoidance_enabled = false
	set_direction(face_left)
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	
	# Conectar o sinal "morreu" do grupo "inimigos"
	add_to_group("inimigos")
	Morte.connect("morreu", Callable(self, "_on_any_enemy_died"))
	for player in get_tree().get_nodes_in_group("player"):
		connect("playermorreu", Callable(self, "mortedoplayer"))


func mortedoplayer():
	print("recebido sinal de morte do player")
	playermorto = true
	return

	
### Processamento Físico
func _physics_process(delta: float) -> void:
	if not attention and not can_detect_player:
		state = "idle"
		velocity = Vector2.ZERO
		anini.play("idle")
		return

	# Verifica se pode atacar
	if podebate and state != "dying" and state != "attack" and !attackcooldown:
		state = "attack"
		anini.play("attacking")
		emit_signal("dano")
	elif podebate and attackcooldown and state != "dying":
		state = "idle"
	
	match state:
		"idle":
			velocity = Vector2.ZERO
			anini.play("idle")
		"chase":
			chase_player(delta)
		"hurt", "dying":
			velocity = Vector2.ZERO
		"attack":
			velocity *= 0.95 # Para completamente durante o ataque

	nav_agent.set_velocity(velocity)
	move_and_slide()

### Funções de Movimento e Detecção
func chase_player(delta: float):
	print("esta em chase")
	if not player or not is_instance_valid(player):
		if state != "dying":
			state = "idle"
		return
	
	nav_agent.target_position = player.global_position
	var next_pos = nav_agent.get_next_path_position()
	var direction = global_position.direction_to(next_pos)
	
	velocity = direction * speed
	nav_agent.set_velocity(velocity)
	anini.play("run")
	set_direction(direction.x < 0)

func _on_detection_area_body_entered(body):
	if body == player and state != "attacking" and state != "dying":
		player_in_range = true
		if attention and state != "dying":
			state = "chase"
func notify_enemy_death():
	Morte.emit_signal("morreu")
### Funções de Eventos


func _on_prox_body_entered(body):
	if body == player:  # Verifica se é o jogador
		podebate = true  # Ativa a permissão para atacar

func _on_prox_body_exited(body):
	if body == player:  # Verifica se é o jogador
		podebate = false  # Desativa a permissão para atacar
		if state != "dying":
			state = "chase"  # Volta para perseguir se o jogador sair da área

func _on_animated_sprite_2d_animation_finished():
	if anini.animation == "Death":
		print("ain")

		queue_free()
	elif anini.animation == "damage":
		if player_in_range:
			state = "chase"
		else:
			state = "idle"
	elif anini.animation == "attacking":
		# Após terminar o ataque, ativa cooldown e volta para chase ou idle
		attackcooldown = true
		timer_2.start()
		if player_in_range:
			state = "chase"
		else:
			state = "idle"

func _on_timer_2_timeout():
	attackcooldown = false  # Reseta o cooldown do ataque
	timer_2.stop()
	
	# Se ainda puder atacar (podebate), volta para ataque automaticamente
	if podebate and state != "dying":
		state = "attack"
		anini.play("attacking")
		emit_signal("dano")

### Funções Auxiliares
func set_direction(is_left: bool):
	anini.scale.x = 1 if is_left else -1


## Quando o bucha do inimigo leva dano
func _on_hit_box_damaged(damage):
	if state != "dying" and !playermorto:
		damagetaken += 1
		print(damagetaken)
		var sangue_instance = sangue.instantiate()
		get_tree().current_scene.add_child(sangue_instance)
		sangue_instance.global_position = global_position
		sangue_instance.z_index = 0

		Morte.emit_signal("morreu")
		emit_signal("morreu")
		state = "dying"
		print("me morri")
		anini.play("Death")

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2):
	velocity = safe_velocity



	
func _on_any_enemy_died():
	attention = true
	print("teste a  a a a  a a a a ")
	if player_in_range and state != "dying":
		print("teste b b b b b bb b bb b ")
		state = "chase"
