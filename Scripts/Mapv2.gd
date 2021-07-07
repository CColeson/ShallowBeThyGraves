extends Node2D

onready var global = get_node("/root/Global")

onready var ui_animator = $UI/Control/AnimationPlayer
onready var spell_state_timer = $UI/Control/SpellSelector/StateTimer
onready var item_state_timer = $UI/Control/ItemSelector/ItemStateTimer
onready var action_label = $UI/Control/ActionLabel

onready var player = find_node("Player", true, false)
onready var lHP = $UI/Control/VBoxContainer/LabelHP
onready var lStamina = $UI/Control/VBoxContainer/LabelStamina

onready var lRound = $UI/Control/RoundContainer/RoundLabel

func _process(delta):
	lHP.text = "HP: " + str(player.health)
	lStamina.text = "Stamina: " + str(player.stamina)
	lRound.text = str(global.current_round)

func _on_Player_change_spell():
	if spell_state_timer.time_left <= 0:
		ui_animator.play("change_spell")
	spell_state_timer.start()

func _on_Player_change_item():
	if item_state_timer.time_left <= 0:
		ui_animator.play("change_item")
	item_state_timer.start()

func _on_StateTimer_timeout():
	ui_animator.play("hide_spells")

func _on_ItemStateTimer_timeout():
	ui_animator.play("hide_items")

func _on_player_usable_entered(message):
	if message != null:
		action_label.text = message

func _on_player_usable_exited():
	action_label.text = ""

func _on_player_used():
	action_label.text = ""






