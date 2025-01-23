extends CharacterBody2D

@export var face_left: bool = true
@onready var anini = $AnimatedSprite2D
@onready var ray_cast = $RayCast2D
@onready var ray_cast_2d_2 = $RayCast2D2
@onready var ray_cast_2d_3 = $RayCast2D3
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
var speed = 80
@export var player : Node2D
var damagetaken = 0
var state = "idle"
var detection_radius = 25

func _ready():
	# Configuração inicial baseada na direção
	set_direction(face_left)

func set_direction(is_left: bool):
	var direction = -1 if is_left else 1
	anini.scale.x = direction*-1
	for ray in [ray_cast, ray_cast_2d_2, ray_cast_2d_3]:
		ray.target_position.x = abs(ray.target_position.x) * direction

func _physics_process(_delta: float) -> void:
	match state:
		"idle":
			velocity = Vector2.ZERO
			anini.play("idle")
			check_for_player()
		"chase":
			chase_player()
		"hurt", "dying":
			velocity = Vector2.ZERO
	
	move_and_slide()

func check_for_player():
	# Verificação de proximidade
	if player and position.distance_to(player.position) <= detection_radius:
		state = "chase"
		return

	for ray in [ray_cast, ray_cast_2d_2, ray_cast_2d_3]:
		if ray.is_colliding():
			var collider = ray.get_collider()
			if collider.name == "player":
				player = collider
				state = "chase"
				return

func chase_player():
	if not player or not is_instance_valid(player):
		state = "idle"
		return
	if player:
		var direction = to_local(nav_agent.get_next_path_position()).normalized()
		var distance = position.distance_to(player.position)
		
		if distance > detection_radius:
			velocity = direction * speed
			anini.play("run")
			set_direction(direction.x < 0)  # Atualiza a direção baseada no movimento
		else:
			velocity = Vector2.ZERO
			anini.play("idle")
		
		# Atualiza a direção dos raycasts para apontar para o jogador
		var to_player = player.global_position - global_position
		for ray in [ray_cast, ray_cast_2d_2, ray_cast_2d_3]:
			ray.target_position = to_player.normalized() * 1000
		
		# Verifica se o jogador ainda está visível ou próximo
		if distance > detection_radius:
			var player_visible = false
			for ray in [ray_cast, ray_cast_2d_2, ray_cast_2d_3]:
				if ray.is_colliding() and ray.get_collider() == player:
					player_visible = true
					break
			
			if not player_visible:
				state = "idle"
				
	else:
		state = "idle"



func makepath()-> void:
	nav_agent.target_position = player.global_position
	


func _on_animated_sprite_2d_animation_finished():
	if anini.animation == "Death":
		print("ain")
		queue_free()
	elif anini.animation == "damage":
		if state == "chase":
			state = "chase"
		else:
			state = "idle"

func _on_hit_box_damaged(damage):
	damagetaken += 1
	print(damagetaken)
	
	state = "dying"
	print("me morri")
	anini.play("Death")

func _on_prox_body_entered(body):
	if state != "dying" and body == player:  # Adicionada verificação
		state = "idle"
		anini.play("idle")

func _on_prox_body_exited(body):
	if state != "dying" and body == player:  # Adicionada verificação
		state = "chase"


func _on_timer_timeout():
	makepath()

