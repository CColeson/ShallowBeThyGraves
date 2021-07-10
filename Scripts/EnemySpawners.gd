""" 
	Manages the amount of enemies spawned per round, when to spawn them, etc.
"""
extends Node
signal zero_enemy_spawns

var rng = RandomNumberGenerator.new()

var early_round_enemy_spawns = [4, 6, 8, 12, 15]
var last_round_spawns = 0
var enemies_to_spawn
var current_round
var enemies_on_map = 0

var automatic_spawn_time = 25
onready var automatic_spawn_timer = $AutomaticSpawnTimer
#^on timeout will spawn enemy just in case the random times are too far in between

onready var round_manager = get_tree().get_current_scene().get_node("RoundManager")
onready var spawners = $Spawners.get_children()

func _ready():
	rng.randomize()
	set_process(false)

func _on_RoundManager_round_start():
	current_round = round_manager.current_round
	
	if current_round <= early_round_enemy_spawns.size():
		enemies_to_spawn = early_round_enemy_spawns[current_round - 1]
	else:
		enemies_to_spawn = last_round_spawns + 3
	last_round_spawns = enemies_to_spawn
	#enemies_to_spawn = 1
	
	for spawner in spawners:
		if spawner.enabled:
			spawner.set_spawn_interval(rng.randi_range(1, 2 * log(5 * current_round) + 15))
			enemies_to_spawn -= 1

func _on_Enemy_enemy_killed(_enemy):
	enemies_on_map -= 1
	if enemies_on_map <= 0 and enemies_to_spawn <= 0:
		emit_signal("zero_enemy_spawns")

func _on_spawner_enemy_spawned(spawner):
	automatic_spawn_timer.start(automatic_spawn_time)
	enemies_on_map += 1
	if enemies_to_spawn > 0:
		var tim = rng.randi_range(1, 2 * log(5 * current_round) + 15)
		spawner.set_spawn_interval(tim)
	enemies_to_spawn -= 1

func _on_AutomaticSpawnTimer_timeout():
	if enemies_on_map <= 0 and enemies_to_spawn > 0:
		#find the timer with the closest time to zero
		var shortest_timer = spawners[0].get_node("Timer")
		for spawner in spawners:
			var timer = spawner.get_node("Timer")
			if spawner.enabled and timer.time_left < shortest_timer.time_left:
				shortest_timer = timer
		shortest_timer.start(0.1)
