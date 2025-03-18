extends CharacterBody2D

var speed := 400.0
var direction := Vector2.RIGHT
var damage := 10
@onready var animated_sprite_2d = $AnimatedSprite2D
var playerrange = false  # Indica se a bala está perto do jogador
var returning := false  # Indica se a bala está voltando
signal bala
var retorno


func _ready():
	# Configura tempo de vida da bala (evita acumulação)
	await get_tree().create_timer(2.0).timeout
	queue_free()

func _physics_process(delta):
	velocity = direction * speed
	move_and_slide()

	# Se a bala está perto e o jogador pressiona "attack", ela retorna
	if playerrange and Input.is_action_just_pressed("attack"):
		return_bullet()

	# Destrói ao colidir
	if get_slide_collision_count() > 0:
		queue_free()

# Define a direção da bala e ajusta a animação
func set_direction(new_direction: Vector2):
	direction = new_direction.normalized()  # Normaliza a direção
	rotation = direction.angle()  # Rotaciona a bala na direção do movimento

# Faz a bala retornar ao contrário
func return_bullet():
	print("A bala retorna!")
	direction = -direction  # Inverte a direção
	rotation = direction.angle()  # Ajusta a rotação para a nova direção
	returning = true  # Ativa o estado de retorno

func _on_area_2d_body_entered(body):
	if body.name == "player":
		print("Bala atingiu: ", body.name)
		emit_signal("bala")
	
		# Se não estiver retornando, aplicar dano
		if not returning:
			if body.has_method("take_damage"):
				body.take_damage(damage)
			queue_free()
	else:
		if returning == true:
			emit_signal("retorno")
			queue_free()

func _on_area_2d_body_exited(body):
	if body.name == "player":
		playerrange = false  # Saiu da área de proximidade


func _on_reflectarea_body_entered(body):
	if body.name == "player":
		playerrange = true
			
	pass # Replace with function body.


func _on_reflectarea_body_exited(body):
	if body.name == "player":
		playerrange = false 
		pass # Replace with function body.
