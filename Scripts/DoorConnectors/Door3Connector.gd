extends Node

onready var root = get_tree().get_current_scene()

func use():
	root.get_node("Navigation2D/Room2_Nav").enabled = true
	root.get_node("Navigation2D/Room2_Nav2").enabled = true
	root.get_node("EnemySpawnsManager/Spawners/Room2_Spawner").enabled = true
