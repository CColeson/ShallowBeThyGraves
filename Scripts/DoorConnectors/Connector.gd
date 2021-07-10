extends Node

func use():
	var root = get_tree().get_current_scene()
	root.get_node("EnemySpawnsManager/Spawners/Room1_Spawner").enabled = true
	root.get_node("Navigation2D/Room1_Nav").enabled = true
	root.get_node("Navigation2D/Room1_Nav2").enabled = true
	get_parent().queue_free()
	
