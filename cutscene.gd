extends Control
@onready var animar = $AnimationPlayer

@onready var cutscene = $"."
@onready var label = $AnimationPlayer/Label
@export var cut : int
func _input(event):
	if Input.is_action_just_pressed("drink"):
		cutscene.visible = false
		label.visible = false 


