extends StaticBody2D
@export var next_scene : String
@onready var transition = $"transition"
@export var inimigos : int
@onready var portaabrida = $Sprite2D
@onready var portafechada = $Sprite2D2




var inimigosmortos : int
# Called when the node enters the scene tree for the first time.
func _ready():
	Morte.connect("morreu", Callable(self, "contagemdeinimigos"))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
func contagemdeinimigos():
	inimigosmortos += 1
	print("morreram: ", inimigosmortos)
	
	if inimigosmortos >= inimigos and portafechada.visible == true:
		portafechada.visible = false
		portaabrida.visible == true
		

func _on_area_2d_body_entered(body):
	if body.name == "player" and inimigosmortos >= inimigos:
		transition.play("fadein")
	pass # Replace with function body.


func _on_transition_animation_finished(anim_name):
	if anim_name == "fadein":
		get_tree().change_scene_to_file(next_scene)
	pass # Replace with function body.
