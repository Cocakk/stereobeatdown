
#uso de "state" no lugar de "estado" para facilitar em situações futuras.
class_name stateIdle extends State


@onready var walk : State=$"../walk"
@onready var attack : State = $"../Attack"


#o que acontece quando o player entra nesse estado?
func Enter () -> void: 
	player._UpdateAnimation("idle")
	pass



#o que acontece quando player deixa este estado
func Exit() -> void:
	pass
	
func Process(_delta : float) -> State:
	if player.direction != Vector2.ZERO:
		return walk
	player.velocity = Vector2.ZERO
	return null

func Physics(_delta : float) -> State:
	return null

func HandleInput( _event: InputEvent) -> State:
	if _event.is_action_pressed("attack"):
		return attack
	return null

