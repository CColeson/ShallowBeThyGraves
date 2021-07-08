extends Node
signal start_door_open

onready var global = get_node("/root/Global")

func use():
	pass

func _on_RoundStartArea_body_entered(body):
	var parent = get_parent()
	if !parent.is_closed and global.game_state != global.game_states.POSTROUND and body.get_class() == "Player":
		parent.close(false)


func _on_RoundManager_round_start():
	var parent = get_parent()
	parent.close(false)
