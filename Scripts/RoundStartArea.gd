extends Area2D

func _on_RoundStartArea_body_entered(body):
	if body.get_class() == "Player":
		$CollisionShape2D.set_deferred("disabled", false)
