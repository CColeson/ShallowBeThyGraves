extends Node

onready var root = get_tree().get_current_scene()

func use():
	root.get_node("Navigation2D/Room5_Nav").enabled = true
	root.get_node("EnemySpawnsManager/Spawners/Room5_Spawner").enabled = true
