extends KinematicBody2D

var rng = RandomNumberGenerator.new()
var direction = 1
var velocity : Vector2
var distance_to_travel
var original_position
var experience_points

func _ready():
	rng.randomize()
	$Light2D.energy = rng.randf_range(0.5, 1.3)
	var s =  rng.randf_range(1,1.5)
	scale *= s
	$AnimationPlayer.play("default")
	$AnimationPlayer.advance(rng.randf_range(0, $AnimationPlayer.get_animation("default").length))
	
	var direction = rng.randf_range(0, 360)
	var speed = rng.randf_range(60, 90)
	var x = speed * cos(direction)
	var y = speed * sin(direction)
	velocity = Vector2(x, y)
	distance_to_travel = rng.randi_range(1, 20)
	original_position = position
	
	
func _physics_process(_delta):
	if original_position.distance_to(position) < distance_to_travel:
		move_and_slide(velocity)
	else:
		$CollisionShape2D.disabled = true
		
func pickup(pickuper):
	if (pickuper.has_method("pickup_exp") 
	and original_position.distance_to(position) >= distance_to_travel):
		pickuper.pickup_exp(self)
		queue_free()
