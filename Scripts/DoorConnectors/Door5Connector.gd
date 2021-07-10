extends Node


onready var root = get_tree().get_current_scene()

func use():
	root.get_node("EnemySpawnsManager/Spawners/Room3_Spawner").enabled = true
	root.get_node("EnemySpawnsManager/Spawners/Room3_Spawner2").enabled = true
	root.get_node("Navigation2D/Room3_Nav").enabled = true
	root.get_node("Navigation2D/Room3_Nav2").enabled = true
	root.get_node("Navigation2D/Room3_Nav3").enabled = true
	root.get_node("Navigation2D/Room3_Nav4").enabled = true
	root.get_node("YSort/Walls/Wall_Obstacle").queue_free()
	root.get_node("YSort/Walls/Wall_Obstacle2").queue_free()
	root.get_node("YSort/Walls/Wall_Obstacle3").queue_free()
	root.get_node("YSort/Walls/Wall_Obstacle4").queue_free()
	root.get_node("EnemySpawnsManager/Spawners/Room4_Spawner").enabled = true
	root.get_node("EnemySpawnsManager/Spawners/Room4_Spawner2").enabled = true
	root.get_node("EnemySpawnsManager/Spawners/Room4_Spawner3").enabled = true
	root.get_node("EnemySpawnsManager/Spawners/Room4_Spawner4").enabled = true
	root.get_node("Navigation2D/Room4_Nav").enabled = true
	root.get_node("Navigation2D/Room4_Nav2").enabled = true
	root.get_node("Navigation2D/Room4_Nav3").enabled = true
	root.get_node("Navigation2D/Room4_Nav4").enabled = true
