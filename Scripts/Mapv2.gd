extends Node2D

onready var player = find_node("Player", true, false)
onready var lHP = $UI/LabelHP
onready var lStamina = $UI/LabelStamina
func _process(delta):
	lHP.text = "HP: " + str(player.health)
	lStamina.text = "Stamina: " + str(player.stamina)
