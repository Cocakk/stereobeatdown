extends CharacterBody2D
@onready var anini = $AnimatedSprite2D

var speed = 80
var player = null
var damagetaken = 0
var state = "idle"
@onready var ray_cast = $RayCast2D
@onready var ray_cast_2d_2 = $RayCast2D2
@onready var ray_cast_2d_3 = $RayCast2D3


func _ready():
	pass

func _physics_process(delta):
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
	
	print("oi")
	if ray_cast.is_colliding():
		print("colidi")
		var collider = ray_cast.get_collider()
		if collider.name == "player":
			print("encontrei o player")
			player = collider
			state = "chase"
			

func chase_player():
	if player:
		var direction = (player.position - position).normalized()
		velocity = direction * speed
		anini.play("run")
		anini.scale.x = -1 if direction.x > 0 else 1
		ray_cast.target_position = direction * 1000
		
		if not ray_cast.is_colliding() or ray_cast.get_collider() != player:
			state = "idle"
			player = null
		




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
