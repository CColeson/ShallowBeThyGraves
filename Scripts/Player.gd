extends KinematicBody2D

var move_speed = 100
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

func _ready():
	animator.active = true
	$Graphics/SpellCaster.hide()
	play_animation("original_state")

func _physics_process(delta):
	match state:
		States.DEFAULT : state_default()
		States.ATTACKING : state_attacking()

func state_default():
	var velocity = Vector2()
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
	
#	if Input.is_action_just_pressed("roll") and velocity != Vector2.ZERO:
#		state = States.ROLLING
		
	if Input.is_action_just_pressed("attack"):
		state = States.ATTACKING
	
	if usable_object != null:
		actionLabel.text = usable_object.usableMessage
		if Input.is_action_just_pressed("use"):
			usable_object.use()
			usable_object = null
			actionLabel.text = ""
	
	move_and_slide(velocity)

func state_attacking():
	play_animation("attack_right")
	var bodiesInArea = $SideMeleeDamageArea.get_overlapping_bodies()
	if !bodiesInArea.empty(): #this could be handled with signals,
		for body in bodiesInArea:#but fuck me do I hate having that many funcs
			if body.has_method("take_damage"):
				body.take_damage(self) 
		
		

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
