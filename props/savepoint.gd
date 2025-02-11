extends StaticBody2D
@onready var label = $Label
var player_in_area = false
@onready var anim = $AnimationPlayer
@onready var audio = $AudioStreamPlayer2D

var key = "beterruba"
# Called when the node enters the scene tree for the first time.
func _ready():
	label.visible = false
	label.text = "Deseja salvar o seu progresso?"
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player_in_area and Input.is_action_just_pressed("attack"):
		label.text = "Progresso salvo!"
		var config = ConfigFile.new()
		config.set_value("Scenes", "Name", get_tree().current_scene.scene_file_path)
		config.save_encrypted_pass("res://save/scenes.cfg", key)
		print("salvo")
	
	
	
	pass


func _on_area_2d_body_entered(body):
	if body.name == "player":
		label.visible = true
		anim.play("show")
		player_in_area = true
		audio.play()
	pass # Replace with function body.


func _on_area_2d_body_exited(body):
	label.visible = false
	player_in_area = false
	audio.stop()
	pass # Replace with function body.
