
#uso de "state" no lugar de "estado" para facilitar em situações futuras.
class_name stateWalk extends State

@export var move_speed : float = 175.0

@onready var idle : State = $"../idle"
@onready var attack : State = $"../Attack"



#o que acontece quando o player entra nesse estado?
func Enter () -> void: 
	player._UpdateAnimation("walk")
	pass



#o que acontece quando player deixa este estado
func Exit() -> void:
	pass
	
func Process(_delta : float) -> State:
	if player.direction==Vector2.ZERO:
		return idle
	player.velocity = player.direction * move_speed
	
	if player._SetDirection():
		player._UpdateAnimation("walk")
		
	return null
func Physics(_delta : float) -> State:
	return null

func HandleInput(_event : InputEvent) -> State:
	if _event.is_action_pressed("attack"):  # Adicione esta verificação
		return attack
	
	return null
