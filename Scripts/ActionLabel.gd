extends Label

#onready var AC = get_parent()
#onready var bg = AC.get_node("NinePatchRect")
#onready var HBox = AC.get_parent()
#onready var VBox = HBox.get_parent()
#onready var MCon = VBox.get_parent()
#
#onready var xAC = AC.rect_size.x
#onready var xbg = bg.rect_size.x
#onready var xHBox = HBox.rect_size.x
#onready var xVBox = VBox.rect_size.x
#onready var xMCon = MCon.rect_size.x
#
#func set_text_and_resize(text):
#	#if self.text != text:
#	self.text = text
#	var width = self.rect_size.x
#	if width + 12 > MCon.rect_size.x:
#		MCon.rect_size.x = width + 12
#		print(width)
#		print(MCon.rect_size.x)
#
