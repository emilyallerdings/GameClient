extends Node2D

@onready var inventory = $Inventory
var stash_main

# Called when the node enters the scene tree for the first time.
func _ready():
	stash_main = get_tree().get_root().get_node("StashMain")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

@rpc("authority", "call_remote", "reliable")
func load_client_stash():
	stash_main.set_player_stash_inventory_grid(self)
	print("test lol also ")
	print(inventory)
	return
