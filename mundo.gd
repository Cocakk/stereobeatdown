extends Node2D

@onready var transition = $transition
@onready var player = $player

func _ready():
	# Assumindo que transition é um AnimationPlayer
	transition.seek(0)
	transition.play("fadeout")

	# Se você quiser definir a posição do nó de transição


# Remova _process se não for usar
# func _process(delta):
#     pass
