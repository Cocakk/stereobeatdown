extends Sprite2D
var rframe : int = randf_range(0, 3)

# Called when the node enters the scene tree for the first time.
func _ready():
	frame = rframe
	z_index = 0
	pass # Replace with function body.

