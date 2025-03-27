extends Node2D
@onready var portal = $portal
var nummortos : int

@onready var player = $player
@export var meta1 : int
@onready var transition = $transition

func _ready():

	transition.seek(0)
	transition.play("fadeout")
	Morte.connect("morreu", Callable(self, "contagemdeinimigos"))



func contagemdeinimigos():
	nummortos += 1
	print("matou ", nummortos)
	if nummortos >= meta1:
		
	
		pass
