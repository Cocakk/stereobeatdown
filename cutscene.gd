extends Control
@onready var animar = $AnimationPlayer
@onready var color_rect = $AnimationPlayer/ColorRect
var candisplaytext = true
@onready var cutscene = $"."
@onready var label = $AnimationPlayer/Label
@export var cut : int
var podepula = false
func _input(event):
	if Input.is_action_just_pressed("drink"):
		cutscene.visible = false
		label.visible = false 
		color_rect.visible = false
	if Input.is_action_just_pressed("attack") and podepula == true:
		get_tree().change_scene_to_file("res://mundo.tscn")

func _ready():
	if cut == 3:
		animar.play("text")
		cutscene.visible = true
		color_rect.visible = true
		label.visible = true
		candisplaytext = false


func _on_area_2d_body_entered(body):
	if candisplaytext == true:
		match cut:
			1:animar.play("first_enemy")
			2: animar.play("second_enemy")
			3: animar.play("text")
			4: animar.play("boss")
		cutscene.visible = true
		color_rect.visible = true
		label.visible = true
		candisplaytext = false
	pass # Replace with function body.


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "text":
		podepula = true
	pass # Replace with function body.
