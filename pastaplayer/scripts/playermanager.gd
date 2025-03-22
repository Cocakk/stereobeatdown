extends Node

# Remove a variável global 'player', vamos buscar dinamicamente
func get_player():
	return get_tree().get_first_node_in_group("player")

func _on_enemy_died():
	var player = get_player()
	if player and player.has_method("oinimigomorreu"):
		player.oinimigomorreu()

func _on_enemy_attack():
	var player = get_player()
	if player and player.has_method("levodano"):
		player.levodano()
