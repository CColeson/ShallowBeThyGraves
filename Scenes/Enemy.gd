extends KinematicBody2D

var path := PoolVector2Array() setget set_path
var speed : = 100
var HP = 150
enum States {DEFAULT, DAMAGED}
var state = States.DEFAULT

#func _physics_process(delta):
#	var move_distance = speed * delta
#	move_along_path(move_distance)

func _process(delta):
	var move_distance = speed * delta
	var nav = get_tree().get_root().find_node("Navigation2D", true, false)
	var player = get_tree().get_root().find_node("Player", true, false)
	
	path = nav.get_simple_path(global_position, player.global_position)
	move_along_path(move_distance)

func move_along_path(distance):
	var start_point := position
	for i in range(path.size()):
		var distance_to_next : = start_point.distance_to(path[0])
		if distance <= distance_to_next and distance >= 0:
			position = start_point.linear_interpolate(path[0], distance / distance_to_next)
			break
		elif distance < 0:
			position = path[0]
			set_process(false)
		distance -= distance_to_next
		start_point = path[0]
		path.remove(0)

func take_damage(attacker):
	#TODO: change state when attacked to Damaged,
	#do something whenever you're damaged
	HP -= 50
	if HP <= 0:
		queue_free()

func set_path(value):
	path = value
	if value.size() == 0:
		return
	set_process(true)
