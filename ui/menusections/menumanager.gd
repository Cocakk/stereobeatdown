extends Node

@onready var control = $Control

@onready var texture = $texture


func _on_button_3_pressed():
	texture.visible = true
	control.visible = false
	pass # Replace with function body.


func _on_jogar_pressed():
	texture.visible = false
	control.visible = true
	pass # Replace with function body.
