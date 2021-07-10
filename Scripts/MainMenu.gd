extends Control

func _on_PlayButton_pressed():
	print("click!")
	get_tree().change_scene("res://Scenes/Maps/Mapv3.tscn")
