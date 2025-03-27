
#uso de "state" no lugar de "estado" para facilitar em situações futuras.
class_name stateDrink extends State

var candrink = true
@onready var walk : State=$"../walk"
@onready var attack : State = $"../Attack"
@onready var idle = $"../idle"
@onready var animation_player = $"../../AnimationPlayer"
signal bebi
var morto = false

#o que acontece quando o player entra nesse estado?
func Enter () -> void: 
	if candrink == true and !morto:
		print("bebendo")
		animation_player.play("bebendo")
		

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
	if _event.is_action_pressed("attack") and !morto:
		return attack
	return null



func _on_animation_player_animation_finished(anim_name):
	if anim_name == "bebendo" and !morto:
		candrink = false
		print("idle")
		emit_signal("bebi")
		return idle
	pass # Replace with function body.


func _on_player_morreu():
	morto = true
	pass # Replace with function body.
