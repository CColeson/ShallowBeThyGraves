extends Node

func use():
	get_parent().queue_free()
