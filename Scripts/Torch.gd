extends StaticBody2D

onready var area = $PlayerInteractableArea


func _on_PlayerInteractableArea_body_entered(body):
	if body.name == "Player": 
		body.promptUse("Press E to light the torch", self)




func _on_PlayerInteractableArea_body_exited(body):
	if body.name == "Player":
		body.closeUsePrompt()
