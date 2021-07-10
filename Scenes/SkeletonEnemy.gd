extends KinematicBody2D
signal enemy_killed
signal player_hit

var path := PoolVector2Array() setget set_path
var speed := 70
var current_speed := speed
var speed_in_torch_light := 30
var HP = 150
enum States {DEFAULT, DAMAGED, ATTACK, CHARGE}
var state = States.DEFAULT
var attacker_position = null
const DAMAGE_SPEED = 350
const DAMAGE_DISTANCE = 25 #Distance to travel after being damaged
var damaged_position = null # our position before taking damage
var experience_points = preload("res://Scenes/ExperiencePoint.tscn")
var health_potion_drop = preload("res://Scenes/HealthPotion.tscn")
var mana_potion_drop = preload("res://Scenes/ManaPotion.tscn")
var rng = RandomNumberGenerator.new()
var facing_right = true
var player_in_attack = true
var attack_frames = [2,3,4]

export var charge_range = 50
export var charge_distance = 80
export var charge_speed = 70
export var attack_range = 25

var charge_point = null
var attack_damage = 25 setget , get_attack_damage

onready var root = get_tree().get_current_scene()
onready var nav = root.find_node("Navigation2D", true, true)
onready var round_manager = root.get_node("RoundManager")
onready var enemy_spawns_manager = root.get_node("EnemySpawnsManager")
onready var player = get_tree().get_current_scene().find_node("Player", true, true)
onready var animator = $Graphics/AnimatedSprite

func get_attack_damage():
	return int(0.16 * pow(round_manager.current_round, 2)) + 25

func _ready():
	connect("enemy_killed", enemy_spawns_manager, "_on_Enemy_enemy_killed")
	connect("player_hit", player, "_on_Enemy_player_hit")
	HP = int((0.3 * pow(round_manager.current_round, 2)) + 150) #gonna have to toy with this
	path = nav.get_simple_path(position, player.position)
	rng.randomize()

func _physics_process(delta):
	match state:
		States.DEFAULT : state_default()
		States.DAMAGED : state_damaged()
		States.ATTACK : state_attack()
		States.CHARGE : state_charge()

func state_default():
	var velocity = Vector2()
	path = nav.get_simple_path(position, player.position)
	path.remove(0) # path[0] is always the starting position for new paths
	if path.size() > 0:
		var direction_to_point = position.direction_to(path[0])
		var distance_to_point = position.distance_to(path[0])
		flip_if_needed(direction_to_point)
		if (distance_to_point <= 0):
			path.remove(0)
			path = nav.get_simple_path(global_position, player.global_position)
		velocity = move_and_slide(direction_to_point * current_speed)
		
	else:
		print("enemy out of nav")
		#if we're out of the nav
		var direction_to_player = global_position.direction_to(player.global_position)
		velocity = move_and_slide(direction_to_player * current_speed)
	if velocity.length() > 0:
			play_animation("run")
	var distance_to_player = position.distance_to(player.position)
#	var dir_to_player = position.direction_to(player.position)
#	if distance_to_player <= charge_range:
#		if rng.randi_range(1, 50) == 25 and dir_to_player.y > 0 and dir_to_player.y < 1:
#			flip_if_needed(dir_to_player)
#			charge_point = dir_to_player * charge_distance
#			play_animation("attack_charge")
#			state = States.CHARGE
#			return
	if distance_to_player <= attack_range:
		if rng.randi_range(1,3) == 2:
			state = States.ATTACK

func state_charge():
	if is_on_wall() or is_on_ceiling() or is_on_floor() or position.distance_to(charge_point) <= 0:
		charge_point = null
		state = States.DEFAULT
	else:
		move_and_slide(position.direction_to(charge_point) * charge_speed)
	

func state_attack():
	var direction = position.direction_to(player.position)
	flip_if_needed(direction)
	if direction.y > 0:
		play_animation("attack_down")
	else:
		play_animation("attack")
	if player_in_attack and attack_frames.find(animator.frame) != -1:
		emit_signal("player_hit", self)
	if global_position.distance_to(player.global_position) > attack_range:
		state = States.DEFAULT
	
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
		HP -= attacker.attack_damage
		attacker_position = attacker.position
		damaged_position = position
		state = States.DAMAGED
		$DamagedTimer.start(1)
		if HP <= 0:
			var drop
			if rng.randi_range(0, 25) == 12:
				match rng.randi_range(0,1):
					0:
						drop = health_potion_drop.instance()
					1:
						drop = mana_potion_drop.instance()
				drop.global_position = global_position
				get_tree().get_root().add_child(drop)
			for _i in range(rng.randi_range(10,15)):
				var ex = experience_points.instance()
				ex.global_position = global_position
				get_tree().get_root().add_child(ex)
			emit_signal("enemy_killed", self)
			$CollisionShape2D.disabled = true
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

func play_animation(animation):
	if animation == "attack_down":
		animator.offset = Vector2(-2, 6)
	else:
		animator.offset = Vector2.ZERO
	
	if animation == "attack_charge":
		$Graphics/Particles2D.emitting = true
	else:
		$Graphics/Particles2D.emitting = false
	animator.play(animation)

func _on_attack_downward_hitbox_area_entered(area):
	var parent = area.get_parent()
	if parent.has_method("get_class") and parent.get_class() == "Player":
			player_in_attack = true

func _on_attack_normal_hitbox_area_entered(area):
	var parent = area.get_parent()
	if parent.has_method("get_class") and parent.get_class() == "Player":
			player_in_attack = true

func _on_attack_normal_hitbox_area_exited(area):
	var parent = area.get_parent()
	if parent.has_method("get_class") and parent.get_class() == "Player":
		player_in_attack = false


func _on_attack_downward_hitbox_area_exited(area):
	var parent = area.get_parent()
	if parent.has_method("get_class") and parent.get_class() == "Player":
		player_in_attack = false


func _on_DamagedTimer_timeout():
	if state == States.DAMAGED:
		state = States.DEFAULT
