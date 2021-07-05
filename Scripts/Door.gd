extends StaticBody2D

export var usable_distance = 30
export var is_usable = true
var usable_message = "Press E to open the door (Starts the next round)"

func _ready():
	$OpenOccluder.visible = false
	$OpenOccluder2.visible = false

func use():
	$Closed.visible = false
	$Open.visible = true
	$ClosedCollision.disabled = true
	$ClosedOccluder.visible = false
	$OpenOccluder.visible = true
	$OpenOccluder2.visible = true
	is_usable = false

