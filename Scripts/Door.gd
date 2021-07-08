extends StaticBody2D
signal cant_afford_door

export var usable_distance = 30
export var is_usable = true
export var usable_message = "Press E to open the door (Starts the next round)"
export var show_left_frame = true
export var show_right_frame = true
export var opening_price = 0
var is_closed = true

func _ready():
	$OpenOccluder.visible = false
	$OpenOccluder2.visible = false
	$FramePieces/LeftFrame.visible = show_left_frame
	$FramePieces/RightFrame.visible = show_right_frame
	var root = get_tree().get_current_scene()
	connect("cant_afford_door", root, "_on_Door_cant_afford_door")

func use(caller):
	if (caller.blood_fragments >= opening_price):
		is_closed = false
		$Closed.visible = false
		$Open.visible = true
		$ClosedCollision.disabled = true
		$ClosedOccluder.visible = false
		$OpenOccluder.visible = true
		$OpenOccluder2.visible = true
		is_usable = false
		
		var map_connector = get_node_or_null("Connector")
		#Considering doors can be used to trigger a multitude of events
		#childing a plain Node and controlling other scene elements from there
		#should prove useful
		if map_connector != null and map_connector.has_method("use"):
			map_connector.use()
		return true
	else:
		emit_signal("cant_afford_door", opening_price - caller.blood_fragments)
		return false

func close(is_usable):
	is_closed = true
	$Closed.visible = true
	$Open.visible = false
	$ClosedCollision.set_deferred("disabled", false)
	$ClosedOccluder.visible = true
	$OpenOccluder.visible = false
	$OpenOccluder2.visible = false
	self.is_usable = is_usable
