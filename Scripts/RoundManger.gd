"""
	Game currently has three states:
		-Preround: Starting game state; also started after the player enters
				   the start door during a Postround state.
		-Round: Game state during each wave of enemies. Starts either when the
				player leaves the starting area or when the between_round_timer
				timeouts
		-Postround: Game state after the player has killed every enemy
"""
extends Node
signal round_start
signal preround_start
signal postround_start
#onready var round_manger = get_tree().get_current_scene().get_node("RoundManager")

var round_number = 0
enum game_states {PREROUND, ROUND, POSTROUND}
var game_state = game_states.PREROUND
var current_round := 0
var time_between_rounds = 60
onready var between_round_timer = $BetweenRoundTimer

func _on_RoundStartArea_body_entered(body):
	if body.get_class() == "Player" and game_state == game_states.PREROUND:
		current_round += 1
		game_state = game_states.ROUND
		emit_signal("round_start")


func _on_EnemySpawnsManager_zero_enemy_spawns():
	game_state = game_states.POSTROUND
	between_round_timer.start(time_between_rounds)
	emit_signal("postround_start")


func _on_BetweenRoundTimer_timeout():
	if game_state != game_states.ROUND:
		current_round += 1
		game_state = game_states.ROUND
		emit_signal("round_start")


func _on_Preround_Area_body_entered(_body):
	if game_state == game_states.POSTROUND:
		game_state = game_states.PREROUND
		emit_signal("preround_start")
