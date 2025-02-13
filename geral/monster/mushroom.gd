extends CharacterBody2D

@export var face_left: bool = true
@onready var anini = $AnimatedSprite2D
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@onready var detection_area = $Area2D
@onready var detectionshape = $Area2D/CollisionShape2D
##
signal morreu
##
var speed = 80
@export var player : Node2D
var damagetaken = 0
var state = "idle"
var player_in_range = false

func _ready():
	set_direction(face_left)
	detection_area.body_entered.connect(_on_detection_area_body_entered)

	
	var overlapping = detection_area.get_overlapping_bodies()
	for body in overlapping:
		if body == player:
			player_in_range = true
			state = "chase"

func set_direction(is_left: bool):
	anini.scale.x = 1 if is_left else -1

func _physics_process(delta: float) -> void:
	match state:
		"idle":
			velocity = Vector2.ZERO
			anini.play("idle")
		"chase":
			chase_player(delta)
		"hurt", "dying":
			velocity = Vector2.ZERO

	
	move_and_slide()

func chase_player(delta: float):
	if not player or not is_instance_valid(player):
		state = "idle"
		return
	
	nav_agent.target_position = player.global_position
	var next_pos = nav_agent.get_next_path_position()
	var direction = global_position.direction_to(next_pos)
	
	velocity = direction * speed
	anini.play("run")
	set_direction(direction.x < 0)

func _on_detection_area_body_entered(body):
	if body == player:
		player_in_range = true
		state = "chase"


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
	emit_signal("morreu")
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
	pass

