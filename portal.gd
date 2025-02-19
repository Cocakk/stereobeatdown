extends StaticBody2D
@export var next_scene : String
@onready var transition = $"../transition"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_body_entered(body):
	if body.name == "player":
		transition.play("fadein")
	pass # Replace with function body.


func _on_transition_animation_finished(anim_name):
	if anim_name == "fadein":
		get_tree().change_scene_to_file(next_scene)
	pass # Replace with function body.
