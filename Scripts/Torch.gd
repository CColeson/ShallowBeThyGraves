extends StaticBody2D

export var usableDistance = 30
var usableMessage = "Press E to light the torch"
export var is_usable = true

func _ready():
	$AnimatedSprite.play("default")
	$AnimatedSprite.frame = 0
	$AnimatedSprite.stop()
	$Light2D.enabled = false
	$Light2D.color = get_node("/root/Global").light_color

func use():
	$AnimatedSprite.play("used")
	$Light2D.enabled = true
	is_usable = false
