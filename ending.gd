extends Control
@onready var animation_player = $AnimationPlayer


# Called when the node enters the scene tree for the first time.



func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Inicio":
		animation_player.play("polcia1")
	elif anim_name == "polcia1":
		animation_player.play("polcia2")
	elif anim_name == "polcia2":
		animation_player.play("polcia3")
	elif anim_name == "polcia3":
		animation_player.play("polcia4")
	elif anim_name == "polcia4":
		animation_player.play("polcia5")
	elif anim_name == "polcia5":
		animation_player.play("polcia6")
	elif anim_name == "polcia6":
		animation_player.play("polcia7")
	elif anim_name == "polcia7":
		animation_player.play("Kent")
	elif anim_name == "Kent":
		animation_player.play("Kent_2")
	elif anim_name == "Kent_2":
		animation_player.play("Kent_3")
		
	elif anim_name == "Kent_3":
		animation_player.play("Kent_4")
	elif anim_name == "Kent_4":
		animation_player.play("polciafinal")
	elif anim_name == "polciafinal":
		animation_player.play("kent_final")
		
	pass # Replace with function body.
