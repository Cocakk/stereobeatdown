extends CanvasLayer
@export var player_name : LineEdit
@export var color : ColorPickerButton
var key = "beterruba"
func _ready():
	var scene_path = get_tree().current_scene.scene_file_path
	print(scene_path)

func _save():
	var config = ConfigFile.new()
	config.set_value("Scenes", "Name", get_tree().current_scene.scene_file_path)
	config.save_encrypted_pass("res://save/scenes.cfg", key)
	print("salvo")


func _load():
	var config = ConfigFile.new()
	var result = config.load_encrypted_pass("user://settings.cfg", key)
	
	if result == OK:
		player_name.text = config.get_value("Settings", "Name")
		color.color = config.get_value("Settings","Color")
	else:
		printerr("Tem parada errada")



