extends Node3D

@onready var inventory_manager = $InventoryManager



@onready var player_inventory = $PlayerInventory

#@onready var ctrl_inventory_grid_ex = $PlayerInventory/Panel/MarginContainer/CtrlInventoryGridEx

#@onready var ctrl_item_slot_ex = $PlayerInventory/Panel/MarginContainer/ScrollContainer/VBoxContainer/BackpackContainer/HBoxContainer/CenterContainer/InvSlot/CtrlItemSlotEx

var started = false

var client_player = null

func start_game():
	started = true
	$World/WorldEnvironment/AnimationPlayer.play("cycle")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#player_inventory.hide()
	self.show()

func show_inv():
	return

func open_inv_menu():
	
	if !started:
		return
	
	#inventory_manager.open_player_inventory(ClientInfo.player.inventory)
	print(ClientInfo.player.inventory)
	
	var pockets_ctrl_inv = player_inventory.get_pockets_container().get_pockets_ctrl_inv()
	var backpack_slot = player_inventory.get_backpack_container().get_backpack_slot()
	
	pockets_ctrl_inv.inventory = ClientInfo.player.inventory.inventory_grid
	backpack_slot.item_slot = ClientInfo.player.get_backpack_slot()
	
	pockets_ctrl_inv._refresh()
	pockets_ctrl_inv._refresh_field_background_grid()
	
	player_inventory.get_backpack_container().get_backpack_slot()._refresh()
	
	player_inventory.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	return

func close_inv_menu():
	
	if !started:
		return
	inventory_manager.close_all_inventories()
	player_inventory.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	return

# Called when the node enters the scene tree for the first time.
func _ready():
	#player_inventory.hide()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _unhandled_input(event):
	if Input.is_action_just_pressed("pause"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			open_inv_menu()
		elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			close_inv_menu()
