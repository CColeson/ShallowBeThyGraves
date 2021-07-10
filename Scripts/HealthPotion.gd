extends Sprite


func pickup(pickuper):
	if ("health_potions" in pickuper):
		pickuper.health_potions += 1
		queue_free()
