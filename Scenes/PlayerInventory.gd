extends Control

@onready var backpack_container = $Panel/MarginContainer/ScrollContainer/HBoxContainer/VBoxContainer/BackpackContainer
@onready var pockets_container = $Panel/MarginContainer/ScrollContainer/HBoxContainer/VBoxContainer/PocketsContainer

func get_pockets_container():
	return pockets_container

func get_backpack_container():
	return backpack_container

# Called when the node enters the scene tree for the first time.
func _ready():
	self.hide()
	#size.y = DisplayServer.window_get_size().y
	#size.x = (DisplayServer.window_get_size().x / 2) - (DisplayServer.window_get_size().x / 16)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass
