extends Control
var key = "beterruba"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	var config = ConfigFile.new()
	var err = config.load_encrypted_pass("res://save/scenes.cfg", key)
	print("aqui ta funcionando")
	if err == OK:
		print("o err ta ok")
		var scene_path = config.get_value("Scenes", "Name")
		if scene_path:
			print(scene_path)
			print("olha, achei")
			# Load the scene using the retrieved path
			get_tree().change_scene_to_file(scene_path)
		else:
			print("Nenhuma cena salva encontrada")
	else:
		print("Erro ao carregar o arquivo de configuração")
	pass # Replace with function body.


func _on_button_2_pressed():
	get_tree().change_scene_to_file("res://ui/menusections/menumanager.tscn")
	pass # Replace with function body.
