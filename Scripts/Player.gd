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
var usableObject = null

func _ready():
	animator.active = true
	play_animation("original_state")

func _physics_process(delta):
	match state:
		States.DEFAULT : state_default()

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

	if Input.is_action_just_pressed("roll") and velocity != Vector2.ZERO:
		state = States.ROLLING
		
	if Input.is_action_just_pressed("attack"):
		state = States.ATTACKING
		
	if usableObject && position.distance_to(usableObject.position) < usableObject.x:#todo:
		pass
		
	

	move_and_slide(velocity)

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

func promptUse(message, object):
	$Label.text = message
	usableObject = object
	
