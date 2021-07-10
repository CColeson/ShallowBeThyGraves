""" 
	Enemy spawners should have ZERO knowledge of how many enemies they are to 
	spawn. They have ONE primary function: To Spawn new Enemies. Any higher 
	logic should be handled by the EnemySpawnsManager.
"""
extends Sprite
class_name EnemySpawner

signal enemy_spawned

var enemy = preload("res://Scenes/SkeletonEnemy.tscn")
onready var enemy_parent = get_tree().get_current_scene().get_node("YSort")

export var enabled = false

func _ready():
	connect("enemy_spawned", get_parent().get_parent(), "_on_spawner_enemy_spawned")

func set_spawn_interval(time):
	$Timer.start(time)

func _on_Timer_timeout():
	print("enemy_spawned")
	var new_enemy = enemy.instance()
	enemy_parent.add_child(new_enemy)
	new_enemy.global_position = self.global_position
	emit_signal("enemy_spawned", self)

func get_class():
	return "EnemySpawner"
