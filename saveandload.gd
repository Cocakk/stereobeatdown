extends CanvasLayer
@export var player_name : LineEdit
@export var color : ColorPickerButton
var key = "beterruba"


func _save():
	var config = ConfigFile.new()
	config.set_value("Settings", "Name", player_name.text)
	config.set_value("Settings", "Color", color.color)
	config.save_encrypted_pass("user://settings.cfg", key)
	print("salvo")


func _load():
	var config = ConfigFile.new()
	var result = config.load_encrypted_pass("user://settings.cfg", key)
	
	if result == OK:
		player_name.text = config.get_value("Settings", "Name")
		color.color = config.get_value("Settings","Color")
	else:
		printerr("Tem parada errada")
