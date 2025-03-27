extends AudioStreamPlayer2D
var canplay = true
@export var inimigosmax : int
var inimigos = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	Morte.connect("morreu", Callable(self, "contagemdeinimigos"))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func contagemdeinimigos():
	if canplay == true:
		play()
		canplay = false
	if inimigosmax <= inimigos:
		stop()

func _on_jorge_morreu():
	if canplay == true:
		play()
		canplay = false
	pass # Replace with function body.
