extends CharacterBody2D

var speed := 400.0
var direction := Vector2.RIGHT
var damage := 10
@onready var animated_sprite_2d = $AnimatedSprite2D

signal bala
##o nome das animações é "horizontal", "vertical" e "diagonal"



func _ready():
	# Configura tempo de vida da bala (evita acumulação)
	await get_tree().create_timer(2.0).timeout
	queue_free()

func _physics_process(delta):
	velocity = direction * speed
	move_and_slide()
	
	# Destrói ao colidir
	if get_slide_collision_count() > 0:
		queue_free()

# Adicione esta função que está faltando!
func set_direction(new_direction: Vector2):
	direction = new_direction
	rotation = direction.angle()  # Opcional: rotaciona a bala na direção do movimento

func _on_body_entered(body):
	print("Bala atingiu: ", body.name)
	emit_signal("bala")
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
