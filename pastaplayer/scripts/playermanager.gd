extends Node

var player

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _on_enemy_died():
	if player:
		print("teste minecraft")
		player.oinimigomorreu()

func _on_enemy_attack():
	if player:
		print("teste roblox")
		player.levodano()
