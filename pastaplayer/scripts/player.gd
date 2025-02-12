class_name Player extends CharacterBody2D

#essa é a raiz do código, tudo que fica nessa parte pode ser usada em qualquer parte do codigo, váriaveis criadas
#em partes especificas só podem ficar em sua própria "área"
var cardinal_direction : Vector2 = Vector2.DOWN
var direction : Vector2 = Vector2.ZERO
const DIR_4 = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]
@onready var state_machine : Player_StateMachine = $StateMachine

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $Sprite2D
signal vencivel
var invencivel = true 
@onready var timer = $Timer


signal DirectionChanged(new_direction : Vector2)
# Called when the node enters the scene tree for the first time.
func _ready():
	state_machine.initialize(self)
	add_to_group("player")

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	
	direction = Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	).normalized()
	
	pass
func _physics_process(_delta):
	move_and_slide()
	

func _SetDirection() -> bool:
	
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
	

	
func _UpdateAnimation ( state : String ) -> void:
	animation_player.play(state + "_" + AnimDirection())
	
pass
func AnimDirection () -> String:
	
	if cardinal_direction == Vector2.DOWN:
		return ("down")
	
	elif cardinal_direction == Vector2.UP:
		return ("up")
	else:
		return ("side")
		



func _on_timer_timeout():
	emit_signal("vencivel")
	invencivel = false
	print("o timer funciona perfeitamente") 
	timer.stop()
	pass # Replace with function body.


func _on_attack_reload():
	timer.start() ##inserir um reload de timer, isso é só um teste btw...
	pass # Replace with function body.
