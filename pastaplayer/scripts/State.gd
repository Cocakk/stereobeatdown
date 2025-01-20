
#uso de "state" no lugar de "estado" para facilitar em situações futuras.
class_name State extends Node

static var player: Player

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

#o que acontece quando o player entra nesse estado?
func Enter () -> void: 
	pass



#o que acontece quando player deixa este estado
func Exit() -> void:
	pass
	
func Process(_delta : float) -> State:
	return null

func Physics(_delta : float) -> State:
	return null

func HandleInput(_event : InputEvent) -> State:
	return null
