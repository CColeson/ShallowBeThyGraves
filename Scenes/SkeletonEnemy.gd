extends KinematicBody2D

var path := PoolVector2Array() setget set_path
var speed := 60
var current_speed := speed
var speed_in_torch_light := 30
var HP = 150
enum States {DEFAULT, DAMAGED}
var state = States.DEFAULT
var attacker_position = null
const DAMAGE_SPEED = 350
const DAMAGE_DISTANCE = 25 #Distance to travel after being damaged
var damaged_position = null # our position before taking damage
var experience_points = preload("res://Scenes/ExperiencePoint.tscn")
var rng = RandomNumberGenerator.new()
var facing_right = true

onready var nav = get_tree().get_current_scene().find_node("Navigation2D", true, true)


func _physics_process(delta):
	match state:
		States.DEFAULT: state_default(delta)
		States.DAMAGED: state_damaged()
		

func state_default(delta):
	var move_distance = current_speed * delta
	var player = get_tree().get_current_scene().find_node("Player", true, true)
	path = nav.get_simple_path(position, player.position)
	var direction = position.direction_to(player.position)
	flip_if_needed(direction)
	var start_point = position
	for i in range(path.size()):
		var distance_to_next = start_point.distance_to(path[0])
		if move_distance <= distance_to_next and move_distance >= 0:
			position = start_point.linear_interpolate(path[0], move_distance / distance_to_next)
			break
		elif move_distance < 0.0:
			position = path[0]
			#set_process(false)
			break
		move_distance -= distance_to_next
		start_point = path[0]
		path.remove(0)



func state_damaged():
	if damaged_position != null:
		if position.distance_to(damaged_position) < DAMAGE_DISTANCE and $DamagedTimer.time_left > 0:
			var direction = position.angle_to_point(attacker_position)
			var y = DAMAGE_SPEED * sin(direction)
			var x = DAMAGE_SPEED * cos(direction)
			var velocity = Vector2(x, y)
			move_and_slide(velocity)
		else:
			state = States.DEFAULT

func take_damage(attacker):
	#TODO: change state when attacked to Damaged,
	#do something whenever you're damaged
	if state != States.DAMAGED:
		HP -= attacker.attackDamage
		attacker_position = attacker.position
		damaged_position = position
		state = States.DAMAGED
		$DamagedTimer.start()
		if HP <= 0:
			for _i in range(rng.randi_range(10,15)):
				var ex = experience_points.instance()
				ex.global_position = global_position
				get_tree().get_root().add_child(ex)
			queue_free()

func flip_if_needed(vec):
	#why does this function feel so dirty
	if vec.x > 0 and !facing_right:
		scale.x *= -1
		facing_right = !facing_right
	elif vec.x < 0 and facing_right:
		scale.x *= -1
		facing_right = !facing_right

func set_path(value):
	path = value
	if value.size() == 0:
		return
	#set_process(true)

func on_torch_light_enter():
	current_speed = speed_in_torch_light

func on_torch_light_exit():
	current_speed = speed 
