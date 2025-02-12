
#uso de "state" no lugar de "estado" para facilitar em situações futuras.
class_name stateAttack extends State

@export var attack_sound : AudioStream
@onready var walk : State=$"../walk"
@onready var attack : State = $"."
@onready var hurt_box : HurtBox = %AttackHurtBox
@onready var animation_player = $"../../AnimationPlayer"
@onready var idle = $"../idle"
@onready var attack_anim = $"../../Sprite2D/AttackEffectSprite/AnimationPlayer"
@onready var audio : AudioStreamPlayer2D = $"../../Audio/AudioStreamPlayer2D"
@export_range (1,20,0.5) var decelerate_speed : float = 5.0
@export var dash_speed : float = 300.0
var dash_duration : float = 0.2
var dash_timer : float = 0.0
signal reload
var attacking : bool = false

#o que acontece quando o player entra nesse estado?
func Enter () -> void: 
	player._UpdateAnimation("attack")
	attack_anim.play("attack_" + player.AnimDirection())
	animation_player.animation_finished.connect(EndAttack)
	
	audio.stream = attack_sound
	audio.pitch_scale = randf_range(0.9,1.1)
	audio.play()
	attacking = true
	if player.direction != Vector2.ZERO:
		player.velocity = player.direction * dash_speed
	
	await get_tree().create_timer(0.075).timeout
	hurt_box.monitoring = true

	
	pass



#o que acontece quando player deixa este estado
func Exit() -> void:
	animation_player.animation_finished.connect(EndAttack)
	attacking = false
	hurt_box.monitoring = false
	dash_timer = 0.0
	pass
	
func Process(_delta : float) -> State:
	
	
	
	if attacking:
		if dash_timer < dash_duration:
			dash_timer += _delta
			emit_signal("reload")
		else:
			player.velocity = player.velocity.move_toward(Vector2.ZERO, decelerate_speed * _delta)
	else:
		player.velocity = player.velocity.move_toward(Vector2.ZERO, decelerate_speed * _delta)
	
	
	
	
	
	if attacking == false:
		if player.direction == Vector2.ZERO:
			return idle
		else:
			return walk
	return null

func Physics(_delta : float) -> State:
	return null

func HandleInput(_event: InputEvent) -> State:
	
	return null

func EndAttack(_newAnimName : String)-> void:
	attacking = false
