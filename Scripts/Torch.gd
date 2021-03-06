extends StaticBody2D

export var usable_distance = 30
var usable_message = "Press E to light the torch"
export var is_usable = true
export var already_lit = false #Light the torch on round_start and flame never dies

func _ready():
	$AnimatedSprite.play("default")
	$AnimatedSprite.frame = 0
	$AnimatedSprite.stop()
	$Light2D.color = get_node("/root/Global").light_color
	$SlowEnemyArea.monitoring = false
	if already_lit:
		use()

func use(caller = null):
	$Timer.start()
	$AnimatedSprite.play("used")
	$AnimationPlayer.play("default")
	$Light2D.enabled = true
	is_usable = false
	$SlowEnemyArea.monitoring = true
	if caller != null:
		if "blood_fragments" in caller:
			caller.blood_fragments += 5
	return true

func _on_SlowEnemyArea_body_entered(body):
	if body.has_method("on_torch_light_enter"):
		body.on_torch_light_enter() 


func _on_SlowEnemyArea_body_exited(body):
	if body.has_method("on_torch_light_exit"):
		body.on_torch_light_exit()

func _on_Timer_timeout():
	if !already_lit:
		is_usable = true
		$AnimatedSprite.play("default")
		$AnimatedSprite.frame = 0
		$AnimatedSprite.stop()
		$SlowEnemyArea.monitoring = false
		$Light2D.enabled = false
