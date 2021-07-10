extends KinematicBody2D
class_name Player

signal change_spell
signal change_item
signal player_usable_entered
signal player_usable_exited
signal player_used
signal player_death

const DAMAGE_SPEED = 350
const DAMAGE_DISTANCE = 25 #Distance to travel after being damaged
var damaged_position = null # our position before taking damage
var attacker_position = null

var move_speed = 65
var roll_speed = 140
var roll_stamina_cost = 20
var attack_stamina_cost = 10
var facing_right = true
var attributes = {
	"vitality" : 1,
	"strength" : 1,
	"conviction" : 1
}
enum States {DEFAULT, ATTACKING, ROLLING, SPELLCASTING, DAMAGED, DEATH}
var state = States.DEFAULT
onready var animator = $AnimationTree
var usable_objects = []
var attack_damage = 20 #TODO getter that multiplies by a skill
var max_health = 100 #TODO getter that multiplies by a skill
var health = max_health
var max_mana = 70
var mana = 70
var stamina = 50 #TODO getter that multiplies by a skill
var stamina_regen_rate = 30#TODO regen that shit somehow
var velocity := Vector2()
var blood_fragments = 0

var mana_potions = 0
var health_potions = 0

func _ready():
	animator.active = true
	$Graphics/SpellCaster.hide()
	play_animation("original_state")
	var UI = get_tree().get_current_scene().get_node("UI")
	connect("player_usable_exited", UI, "_on_player_usable_exited")
	connect("player_usable_entered", UI, "_on_player_usable_entered")
	connect("player_used", UI, "_on_player_used")
	connect("change_spell", UI, "_on_Player_change_spell")
	connect("change_item", UI, "_on_Player_change_item")

func _physics_process(_delta):
	match state:
		States.DEFAULT : state_default()
		States.ATTACKING : state_attacking()
		States.ROLLING : state_rolling()
		States.DAMAGED : state_damaged()
		States.DEATH : state_death()

func state_death():
	move_and_slide(Vector2.ZERO)

func state_default():
	stamina = 50 #TODO: get rid of this, make stamina regeneration
	velocity = Vector2()
	if Input.is_action_pressed("up"):
		velocity.y = -1
	if Input.is_action_pressed("down"):
		velocity.y = 1
	if Input.is_action_pressed("right"):
		velocity.x = 1
	if Input.is_action_pressed("left"):
		velocity.x = -1
	
	flip_if_needed(velocity)
	velocity *= move_speed
	if velocity != Vector2.ZERO:
		play_animation("walk")
	else:
		play_animation("original_state")
	
	if Input.is_action_just_pressed("change_spell"):
		emit_signal("change_spell")
	if Input.is_action_just_pressed("change_item"):
		emit_signal("change_item")
	#These two conditionals must be after velocity is determined
	if (Input.is_action_just_pressed("roll") and velocity != Vector2.ZERO  and stamina - roll_stamina_cost >= 0):
		stamina -= roll_stamina_cost
		state = States.ROLLING
	if Input.is_action_just_pressed("attack") and stamina - attack_stamina_cost >= 0:
		stamina -= attack_stamina_cost
		state = States.ATTACKING
	
	check_usables()
	move_and_slide(velocity)

func state_attacking():
	var animation = "attack_right"
	var hitbox = $SideMeleeDamageArea
	if velocity.y < 0:
		animation = "attack_up"
		hitbox = $TopMeleeDamageArea
	elif velocity.y > 0:
		animation = "attack_down"
		hitbox = $BottomMeleeDamageArea
		
	play_animation(animation)
	var areas_in_area = hitbox.get_overlapping_areas()
	if !areas_in_area.empty(): #this could be handled with signals,
		for area in areas_in_area:#but fuck me do I hate having that many funcs
			var parent = area.get_parent()
			if parent.has_method("take_damage"):
				parent.take_damage(self)

func state_rolling():
	play_animation("roll")
	move_and_slide(velocity.normalized() * roll_speed)
	
func state_damaged():
	if damaged_position != null:
		if position.distance_to(damaged_position) < DAMAGE_DISTANCE and $DamagedTimer.time_left > 0:
			var direction = position.angle_to_point(attacker_position)
			var y = DAMAGE_SPEED * sin(direction)
			var x = DAMAGE_SPEED * cos(direction)
			var velocity = Vector2(x, y)
			move_and_slide(velocity)
		elif health > 0:
			state = States.DEFAULT
		else:
			state = States.DEATH

func flip_if_needed(vec):
	#why does this function feel so dirty
	if vec.x > 0 and !facing_right:
		scale.x *= -1
		facing_right = !facing_right
	elif vec.x < 0 and facing_right:
		scale.x *= -1
		facing_right = !facing_right

func play_animation(animation_name):
	# stops multiple calls to the same animation
	var animator_state = animator.get("parameters/playback")
	if animator_state.get_current_node() != animation_name:
		if not animation_name in animator_state.get_travel_path():
			animator_state.travel(animation_name)

func _on_UsableRange_body_entered(body):
	if "is_usable" in body:
		if body.is_usable:
			usable_objects.append(body)

func _on_UsableRange_body_exited(body):
	if "is_usable" in body and usable_objects.has(body):
		if body.get_class() == "Door" and body.has_method("on_player_UsableRange_exit"):
			#I hate this if statement, probably a much better way to do this, also the and clause is probably unneeded
			body.on_player_UsableRange_exit()
		usable_objects.erase(body)
		emit_signal("player_usable_exited", self)#UI updates here

func _on_attack_animation_finish():
	if state == States.ATTACKING:
		state = States.DEFAULT

func check_usables():
	if usable_objects.size() != 0:
		#get the closest object
		var closest_object = usable_objects[0]
		for i in usable_objects:
			if i.global_position.distance_to(global_position) < closest_object.global_position.distance_to(global_position):
				closest_object = i
		emit_signal("player_usable_entered", closest_object.usable_message)
		if Input.is_action_just_pressed("use"):
			var use_worked = closest_object.use(self)
			if use_worked == true:
				usable_objects.erase(closest_object)
				emit_signal("player_used", self)

func _on_roll_animation_finish():
	if state == States.ROLLING:
		state = States.DEFAULT

func pickup_exp(ex):
	blood_fragments += ex.value
	
func _on_PickupRange_body_entered(body):
	if body.has_method("pickup"):
		body.pickup(self)

func _on_PickupRange_area_entered(area):
	var parent = area.get_parent()
	if parent.has_method("pickup"):
		parent.pickup(self)

func _on_Enemy_player_hit(enemy):
	if state != States.DAMAGED and state != States.DEATH:
		health -= enemy.attack_damage
		attacker_position = enemy.position
		damaged_position = position
		state = States.DAMAGED
		$DamagedTimer.start(0.3)
		if health <= 0:
			emit_signal("player_death", self)
			$CollisionShape2D.disabled = true

func get_class():
	return "Player"


func _on_RoundManager_postround_start():
	health = max_health
	mana = max_mana
