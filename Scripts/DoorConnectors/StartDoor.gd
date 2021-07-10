extends Node

onready var round_manager = get_tree().get_current_scene().get_node("RoundManager")
onready var parent = get_parent()

func use():
	pass

func _on_RoundStartArea_body_entered(body):
	if !parent.is_closed and round_manager.game_state != round_manager.game_states.POSTROUND and body.get_class() == "Player":
		parent.close(false)


func _on_RoundManager_round_start():
	parent.close(false)


func _on_RoundManager_postround_start():
	parent.open()


func _on_RoundManager_preround_start():
	parent.close(true)
