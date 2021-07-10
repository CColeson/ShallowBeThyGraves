extends StaticBody2D

export var is_colidable = true

func _ready():
	$CollisionShape2D.disabled = !is_colidable
