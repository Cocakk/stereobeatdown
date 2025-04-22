extends CanvasLayer
@onready var animation_player = $AnimationPlayer



func _on_animation_player_animation_finished(anim_name):
	if anim_name == "nada_2":
		get_tree().change_scene_to_file("res://ending.tscn")
	pass # Replace with function body.


func _on_jorge_permadeath():
	animation_player.play("nada_2")
	pass # Replace with function body.
