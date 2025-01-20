extends CharacterBody2D

var speed = 25
var player_chase = false
var player = null

func _ready():
	pass
func _physics_process(_delta):

	if player_chase:
		print("achei")
		position += (player.position - position)/speed
		move_and_slide()








func _on_detection_area_area_entered(body):
	print("detectado")
	player = body
	player_chase = true
	pass # Replace with function body.



func _on_detection_area_area_exited(_body):

	print("n to veno")
	player = null
	player_chase = false
	
	pass # Replace with function body.
