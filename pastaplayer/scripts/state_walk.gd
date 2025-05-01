
#uso de "state" no lugar de "estado" para facilitar em situações futuras.
class_name stateWalk extends State

@export var move_speed : float = 175.0
var morto = false
@onready var idle : State = $"../idle"
@onready var attack : State = $"../Attack"
@onready var drink = $"../Node"
@export var walk_sound: AudioStream
@onready var audio_stream_player_2d = $"../../Audio/AudioStreamPlayer2D"


#o que acontece quando o player entra nesse estado?
func Enter () -> void: 
	player._UpdateAnimation("walk")
	pass



#o que acontece quando player deixa este estado
func Exit() -> void:
	pass
	
func Process(_delta : float) -> State:
	if player.direction==Vector2.ZERO and !morto:
		if audio_stream_player_2d.playing:
			audio_stream_player_2d.stop()
		return idle
	player.velocity = player.direction * move_speed
	
	if morto:
		player.velocity = player.direction * move_speed * 0
		audio_stream_player_2d.stop()
	elif player._SetDirection():
		if not audio_stream_player_2d.playing:
			audio_stream_player_2d.stream = walk_sound
			audio_stream_player_2d.play()
		player._UpdateAnimation("walk")
		
	return null
func Physics(_delta : float) -> State:
	return null

func HandleInput(_event : InputEvent) -> State:
	if _event.is_action_pressed("attack"):  # Adicione esta verificação
		return attack
	if _event.is_action_pressed("drink"):
		return drink
	return null


func _on_player_morreu():
	morto = true
	pass # Replace with function body.
