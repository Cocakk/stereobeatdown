extends Area2D
@onready var anini = $AnimationPlayer
var meta = randi_range(6, 25)
signal explosion
var morto = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	Morte.connect("morreu", Callable(self, "_on_any_enemy_died"))
	connect("explosion", get_tree().get_first_node_in_group("player").levotiro)
	randomize()

func _on_any_enemy_died():
	morto += 1
	if morto %meta == 0:
		anini.play("alert")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "alert":
		anini.play("explosion")
	pass # Replace with function body.


func _on_body_entered(body):
	if body.name == "player":
		print("a minha arte é uma EXPLOSÃO")
		emit_signal("explosion")
	pass # Replace with function body.
