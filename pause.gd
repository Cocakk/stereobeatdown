extends Control

func _ready():
	get_tree().paused = false
	visible = false
	
	
func resume():
	get_tree().paused = false
	visible = false
	
func pause():
	get_tree().paused = true
	visible = true
	
func testesc():
	if Input.is_action_just_pressed("pause") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("pause") and get_tree().paused == true:
		resume()

func _on_resume_pressed():
	resume()
	pass # Replace with function body.


func _on_restart_pressed():
	get_tree().reload_current_scene()
	pass # Replace with function body.


func _process(delta):
	testesc()
	
func _on_quit_pressed():
	get_tree().change_scene_to_file("res://ui/menusections/menumanager.tscn")
	pass # Replace with function body.
