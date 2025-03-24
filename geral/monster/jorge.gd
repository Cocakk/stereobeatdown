extends CharacterBody2D
@onready var timer = $Timer

@export var face_left: bool = true
@onready var anini = $AnimatedSprite2D
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@onready var detection_area = $Area2D
@onready var detectionshape = $Area2D/CollisionShape2D
@onready var timer_2 = $Timer2
@onready var shoot_timer = $ShootTimer
@onready var ray_cast_2d = $RayCast2D
@onready var bullet_scene = preload("res://geral/bullet/bullet.tscn")
@onready var weapon_point = $weaponpoint
@onready var burst_cooldown_timer = $BurstCoooldownTimer


signal morreu
signal dano

@export var attention = true
var playermorto = false
var speed = 80
@export var player : Node2D
var damagetaken = 0
var last_direction_x = 0

# Sistema de rajadas
@export var burst_size := 3
@export var burst_cooldown := 2.0
var shots_fired := 0
var is_in_cooldown := false

enum STATES { IDLE, CHASE, ATTACK, DYING }
var state : STATES = STATES.IDLE

var podebate = false
var player_in_range = false
var attackcooldown = false
var can_detect_player = false
var preferred_distance = 175

var direction_tolerance = 0.7
var last_player_position: Vector2 = Vector2.ZERO
var position_update_cooldown = 0.5
var update_timer = 0.0

func _ready():
	nav_agent.avoidance_enabled = false
	set_direction(face_left)
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	add_to_group("inimigos")
	Morte.connect("morreu", Callable(self, "_on_any_enemy_died"))

	shoot_timer.wait_time = 0.1
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	shoot_timer.start()

	burst_cooldown_timer.wait_time = burst_cooldown
	burst_cooldown_timer.timeout.connect(_on_burst_cooldown_timeout)

	if player == null:
		player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if not attention and not can_detect_player:
		state = STATES.IDLE
		velocity = Vector2.ZERO
		anini.play("idle")
		return

	if podebate and state != STATES.DYING and state != STATES.ATTACK and !attackcooldown:
		state = STATES.ATTACK
		anini.play("attacking")
		emit_signal("dano")
	elif podebate and attackcooldown and state != STATES.DYING:
		state = STATES.IDLE

	match state:
		STATES.IDLE:
			velocity = Vector2.ZERO
			anini.play("idle")
		STATES.CHASE:
			chase_player(delta)
		STATES.ATTACK:
			velocity *= 0.95
		STATES.DYING:
			velocity = Vector2.ZERO
			anini.play("Death")

	nav_agent.set_velocity(velocity)
	move_and_slide()

func chase_player(delta: float):
	if not player or not is_instance_valid(player):
		if state != STATES.DYING:
			state = STATES.IDLE
		return

	update_timer += delta
	if update_timer >= position_update_cooldown:
		nav_agent.target_position = player.global_position
		update_timer = 0.0

	var distance_to_player = global_position.distance_to(player.global_position)
	var player_direction = (player.global_position - global_position).normalized()

	if distance_to_player < preferred_distance - 20:
		velocity = -player_direction * (speed * 0.5)
	elif distance_to_player > preferred_distance + 20:
		velocity = player_direction * speed
	else:
		velocity = Vector2.ZERO

	var target_direction = sign(player.global_position.x - global_position.x)
	var current_direction = sign(anini.scale.x)
	
	if abs(target_direction - current_direction) > direction_tolerance:
		set_direction(target_direction < 0)

	if velocity.length() > 10:
		anini.play("run")
	else:
		anini.play("idle")
		velocity = Vector2.ZERO

	move_and_slide()

func _on_detection_area_body_entered(body):
	if body == player and state != STATES.ATTACK and state != STATES.DYING:
		player_in_range = true
		if attention == true and state != STATES.DYING:
			state = STATES.CHASE
	elif body.is_in_group("bullets") and body.returning:
		queue_free()
		
func _on_prox_body_entered(body):
	if body == player:
		podebate = true

func _on_prox_body_exited(body):
	if body == player:
		podebate = false
		if state != STATES.DYING:
			state = STATES.CHASE

func _on_animated_sprite_2d_animation_finished():
	if anini.animation == "Death":
		queue_free()
	elif anini.animation == "damage":
		if player_in_range:
			state = STATES.CHASE
		else:
			state = STATES.IDLE
	elif anini.animation == "attacking":
		attackcooldown = true
		timer_2.start()
		if player_in_range:
			state = STATES.CHASE
		else:
			state = STATES.IDLE

func _on_timer_2_timeout():
	attackcooldown = false
	timer_2.stop()
	if podebate and state != STATES.DYING:
		state = STATES.ATTACK
		anini.play("attacking")
		emit_signal("dano")

func set_direction(is_left: bool):
	anini.scale.x = -1 if is_left else 1
	if is_left:
		weapon_point.position.x = -abs(weapon_point.position.x)
	else:
		weapon_point.position.x = abs(weapon_point.position.x)

func _on_any_enemy_died():
	attention = true
	if player_in_range and state != STATES.DYING:
		state = STATES.CHASE

func _on_hit_box_damaged(damage):
	if state != STATES.DYING and !playermorto:
		state = STATES.DYING
		anini.play("Death")
		Morte.emit_signal("morreu")
		emit_signal("morreu")
	elif state == STATES.DYING:
		print("não é possível morrer duas vezes")

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2):
	if state == STATES.CHASE:
		velocity = velocity.lerp(safe_velocity, 0.1)

func _on_shoot_timer_timeout():
	if player and is_instance_valid(player) and state != STATES.DYING and attention and not is_in_cooldown:
		ray_cast_2d.target_position = player.global_position - ray_cast_2d.global_position
		ray_cast_2d.force_raycast_update()

		if ray_cast_2d.is_colliding() and ray_cast_2d.get_collider() == player:
			anini.play("attacking")
			var bullet = bullet_scene.instantiate()
			bullet.global_position = weapon_point.global_position
			var direction = (player.global_position - weapon_point.global_position).normalized()
			bullet.set_direction(direction)
			get_tree().current_scene.add_child(bullet)
			
			shots_fired += 1
			
			if shots_fired >= burst_size:
				is_in_cooldown = true
				burst_cooldown_timer.start()

func _on_burst_cooldown_timeout():
	is_in_cooldown = false
	shots_fired = 0

func debug_info():
	print(
		"Estado: %s\nVelocidade: %s\nPlayer Válido: %s" % [
			str(state),
			str(velocity),
			str(is_instance_valid(player))
		]
	)
