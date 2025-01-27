extends Node

@onready var control = $Control
var savedscene
@onready var texture = $texture
var key = "beterruba"



func _on_button_3_pressed():
	texture.visible = true
	control.visible = false
	


func _on_jogar_pressed():
	texture.visible = false
	control.visible = true
	


func _on_button_pressed(): ##botão de load
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



func _on_button_2_pressed():
	var config = ConfigFile.new()
	var reloadgame = "res://mundo.tscn"
	config.set_value("Scenes", "Name", reloadgame)
	config.save_encrypted_pass("res://save/scenes.cfg", key)
	get_tree().change_scene_to_file("res://mundo.tscn")
	
	
	pass # Replace with function body.


func _on_sair_pressed():
	get_tree().quit()
	pass # Replace with function body.
