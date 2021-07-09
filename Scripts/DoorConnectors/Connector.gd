extends Node

func use():
	var root = get_tree().get_current_scene()
	root.get_node("EnemySpawners/Room1_Spawner").enabled = true
	get_parent().queue_free()
	
