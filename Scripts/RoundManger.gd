extends Node
signal round_start
onready var global = get_node("/root/Global")

func _on_RoundStartArea_body_entered(body):
	if global.game_state != global.game_states.ROUND and body.get_class() == "Player":
		global.current_round += 1
		global.game_state = global.game_states.ROUND
		emit_signal("round_start")
