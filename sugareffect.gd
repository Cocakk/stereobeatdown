extends MarginContainer
@onready var anim = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	for enemy in get_tree().get_nodes_in_group("inimigos"):
		enemy.connect("morreu", Callable(self, "oinimigomorreu"))
	pass # Replace with function body.

func oinimigomorreu():
	print("sugareffect recebe o sinal")
	anim.stop()
	anim.play("loadoff")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "loadoff":
		anim.play("loadoff_2")
	pass # Replace with function body.





func _on_drink_bebi():
	anim.stop()
	anim.play("loadoff")
	pass # Replace with function body.
