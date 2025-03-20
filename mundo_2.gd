extends Node2D
@onready var portal = $portal
var nummortos : int
@onready var transition = $transition
@onready var player = $player
@export var meta1 : int

func _ready():
	# Assumindo que transition é um AnimationPlayer
	transition.seek(0)
	transition.play("fadeout")
	Morte.connect("morreu", Callable(self, "contagemdeinimigos"))

# Remova _process se não for usar
# func _process(delta):
#     pass
func contagemdeinimigos():
	nummortos += 1
	print("matou ", nummortos)
	if nummortos >= meta1:
		
	
		pass
