extends Sprite
signal Fireball
signal Vampiric_Feast
signal Vengeful_Gods_Last_Regret
export(String, "Fireball", "Vampiric_Feast", "Vengeful_Gods_Last_Regret") var spell_name


func pickup(pickuper):
	if ("spells" in pickuper):
		pickuper.spells.append(spell_name)
		emit_signal(spell_name)
		queue_free()
