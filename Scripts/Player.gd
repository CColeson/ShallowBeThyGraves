extends KinematicBody2D
#meme man u suck
var move_speed = 80
var roll_speed = 140
var roll_stamina_cost = 20
var attack_stamina_cost = 10
var facing_right = true
var attributes = {
	"vitality" : 1,
	"strength" : 1,
	"conviction" : 1
}
enum States {DEFAULT, ATTACKING, ROLLING, SPELLCASTING}
var state = States.DEFAULT
onready var animator = $AnimationTree
onready var actionUI = $UI
onready var actionLabel = $UI/Label
var usable_object = null
var attackDamage = 50 #TODO getter that multiplies by a skill
var health = 100 #TODO getter that multiplies by a skill
var stamina = 50 #TODO getter that multiplies by a skill
var stamina_regen_rate = 30#TODO regen that shit somehow
var velocity := Vector2()


func _ready():
	animator.active = true
	$Graphics/SpellCaster.hide()
	play_animation("original_state")

func _physics_process(_delta):
	match state:
		States.DEFAULT : state_default()
		States.ATTACKING : state_attacking()
		States.ROLLING : state_rolling()

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
			usable_object = body

func _on_UsableRange_body_exited(body):
	if "is_usable" in body and usable_object == body:
		usable_object = null
		actionLabel.text = ""

func _on_attack_animation_finish():
	if state == States.ATTACKING:
		state = States.DEFAULT

func check_usables():
	if usable_object != null:
		actionLabel.text = usable_object.usableMessage
		if Input.is_action_just_pressed("use"):
			usable_object.use()
			usable_object = null
			actionLabel.text = ""

func _on_roll_animation_finish():
	if state == States.ROLLING:
		state = States.DEFAULT

func pickup_exp(ex):
	pass
	
func _on_PickupRange_body_entered(body):
	if body.has_method("pickup"):
		body.pickup(self) 

func _on_PickupRange_area_entered(area):
	var parent = area.get_parent()
	if parent.has_method("pickup"):
		parent.pickup(self)
