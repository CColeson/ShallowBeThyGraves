extends Area2D

func _on_RoundManager_round_start():
	$CollisionShape2D.set_deferred("disabled", false)
