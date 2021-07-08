extends Node2D

onready var global = get_node("/root/Global")

onready var ui_animator = $UI/Control/AnimationPlayer
onready var spell_state_timer = $UI/Control/SpellSelector/StateTimer
onready var item_state_timer = $UI/Control/ItemSelector/ItemStateTimer
onready var action_label = $UI/Control/TopLeftUI/VBoxContainer/HBoxContainer/ActionContainer/ActionLabel
onready var action_menu = $UI/Control/TopLeftUI/VBoxContainer/HBoxContainer/ActionContainer
onready var blood_label = $UI/Control/TopLeftUI/VBoxContainer/BloodContainer/BloodLabel

onready var player = find_node("Player", true, false)
onready var lHP = $UI/Control/VBoxContainer/LabelHP
onready var lStamina = $UI/Control/VBoxContainer/LabelStamina

onready var lRound = $UI/Control/TopLeftUI/VBoxContainer/HBoxContainer/RoundContainer/RoundLabel

func _process(delta):
	lHP.text = "HP: " + str(player.health)
	lStamina.text = "Stamina: " + str(player.stamina)
	lRound.text = str(global.current_round)
	blood_label.text = str(player.blood_fragments)

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
		action_label.set_text_and_resize(message)
		if (action_menu.modulate.a == 0):
			play_animation("show_action_menu")
		

func _on_player_usable_exited(player):
	action_label.text = ""
	if (player.usable_objects.size() == 0 and action_menu.modulate.a > 0):
		play_animation("hide_action_menu")
	
func _on_player_used(player):
	action_label.text = ""
	if (player.usable_objects.size() == 0 and action_menu.modulate.a > 0):
		play_animation("hide_action_menu")
	
func play_animation(animation_name):
	# stops multiple calls to the same animation
	if ui_animator.current_animation != animation_name || ui_animator.current_animation != "":
		ui_animator.play(animation_name)
		

func _on_Door_cant_afford_door(required_blood_fragments):
	print("dasdbuni")
	action_label.set_text_and_resize("You need " + str(required_blood_fragments) + " more blood fragments to open this door!")
	if (action_menu.modulate.a == 0):
			play_animation("show_action_menu")
