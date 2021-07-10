extends CanvasLayer

onready var player = get_tree().get_current_scene().find_node("Player", true, true)
onready var round_manager = get_tree().get_current_scene().get_node("RoundManager")
onready var ui_animator = $Control/AnimationPlayer
onready var spell_state_timer = $Control/SpellSelector/StateTimer
onready var item_state_timer = $Control/ItemSelector/ItemStateTimer
onready var action_label = $Control/TopLeftUI/VBoxContainer/HBoxContainer/ActionLabel
onready var action_menu = $Control/TopLeftUI/VBoxContainer/HBoxContainer/ActionLabel
onready var action_menu_animator = $Control/ActionMenuAnimator
onready var blood_label = $Control/TopLeftUI/VBoxContainer/BloodContainer/BloodLabel

#onready var player = find_node("Player", true, false)
onready var lHP = $Control/VBoxContainer/LabelHP
onready var lStamina = $Control/VBoxContainer/LabelStamina

onready var lRound = $Control/TopLeftUI/VBoxContainer/HBoxContainer/RoundContainer/RoundLabel
export var debug_show = true

onready var altselect_mod = Color("#565656")
onready var manapotlabel = $Control/ItemSelector/HBoxContainer/TextureRect2/ManaQuant/Label
onready var healthpotlabel = $Control/ItemSelector/HBoxContainer/TextureRect/HPQuant/Label

func _ready():
	action_menu_animator.play("hide_action_menu")
	if !debug_show:
		$Control.hide()
	

func _process(_delta):
	lHP.text = "HP: " + str(player.health)
	lStamina.text = "Stamina: " + str(player.stamina)
	lRound.text = str(round_manager.current_round)
	blood_label.text = str(player.blood_fragments)
	manapotlabel.text = str(player.mana_potions)
	healthpotlabel.text = str(player.health_potions)
	

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
		if (action_menu.modulate.a == 0):
			play_animation(action_menu_animator, "show_action_menu")

func _on_player_usable_exited(player):
	#action_label.text = ""
	if (player.usable_objects.size() == 0 and action_menu.modulate.a > 0):
		play_animation(action_menu_animator, "hide_action_menu")

func _on_player_used(player):
	#action_label.text = ""
	if (player.usable_objects.size() == 0 and action_menu.modulate.a > 0):
		play_animation(action_menu_animator, "hide_action_menu")

func play_animation(animator, animation_name):
	# stops multiple calls to the same animation
	if animator.current_animation != animation_name || animator.current_animation != "":
		animator.play(animation_name)

func _on_Door_cant_afford_door():
	if (action_menu.modulate.a == 0):
			play_animation(action_menu_animator, "show_action_menu")


func _on_RoundManager_round_start():
	$Control/RoundAnnouncer.text = "Round " + str(round_manager.current_round)
	$Control/RoundAnnounceAnimationPlayer.play("round_announce")
	$Control/ItemSelector/HBoxContainer/TextureRect3.modulate = altselect_mod

func _on_RoundManager_postround_start():
	$Control/RoundAnnouncer.text = "Round Complete!"
	$Control/RoundAnnounceAnimationPlayer.play("round_announce")
	$Control/ItemSelector/HBoxContainer/TextureRect3.modulate = Color("#ffffff")
