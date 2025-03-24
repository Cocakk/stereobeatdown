extends Control

@onready var cutscene = $"."
@onready var label = $AnimationPlayer/Label
@export var cut : int
func _input(event):
	if Input.is_action_just_pressed("drink"):
		cutscene.visible = false
		label.visible = false 

func _ready(): 
	match cut:
		1:
			print("roblox")
		2: 
			print("rpg")
		3:
			print("idk")
	pass
