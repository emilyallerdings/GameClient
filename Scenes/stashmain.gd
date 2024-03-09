extends Control

@onready var player_stash_ctrl = $Panel2/ScrollContainer/PlayerStashCtrl

# Called when the node enters the scene tree for the first time.
func _ready():
	StashServer.send_server_player_info.rpc_id(1, StashServer.player_name)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_player_stash_inventory_grid(stash):
	player_stash_ctrl.inventory = stash.inventory.inventory_grid
