extends Sprite


func pickup(pickuper):
	if ("mana_potions" in pickuper):
		pickuper.mana_potions += 1
		queue_free()
