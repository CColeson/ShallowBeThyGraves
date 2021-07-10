extends Node


onready var root = get_tree().get_current_scene()

func use():
	root.get_node("EnemySpawnsManager/Spawners/Room4_Spawner").enabled = true
	root.get_node("EnemySpawnsManager/Spawners/Room4_Spawner2").enabled = true
	root.get_node("EnemySpawnsManager/Spawners/Room4_Spawner3").enabled = true
	root.get_node("EnemySpawnsManager/Spawners/Room4_Spawner4").enabled = true
	root.get_node("Navigation2D/Room4_Nav").enabled = true
	root.get_node("Navigation2D/Room4_Nav2").enabled = true
	root.get_node("Navigation2D/Room4_Nav3").enabled = true
	root.get_node("Navigation2D/Room4_Nav4").enabled = true
