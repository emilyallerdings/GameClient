extends Control

const INVENTORY_INSTANCE = preload("res://InventoryInstance/inventory_instance.tscn")

var open_inventories = []
var game

# Called when the node enters the scene tree for the first time.
func _ready():
	game = get_parent()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func open_inventory(inv):
	
	if !open_inventories.has(inv):
		var new_inv_inst = INVENTORY_INSTANCE.instantiate()
		new_inv_inst.position.x = (DisplayServer.window_get_size().x / 2) + DisplayServer.window_get_size().x / 4
		new_inv_inst.position.y = (DisplayServer.window_get_size().y / 2)
		new_inv_inst.set_inv(inv)
		add_child(new_inv_inst)
		open_inventories.append(inv)
		
		game.open_inv_menu()
		#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	return
	
func close_inventory(inv_instance):
	if open_inventories.has(inv_instance.inventory):
		open_inventories.erase(inv_instance.inventory)
		inv_instance.queue_free()
	if open_inventories.size() == 0:
		
		game.close_inv_menu()

func close_all_inventories():
	for inv_instance in get_children():
		open_inventories.erase(inv_instance.inventory)
		inv_instance.queue_free()
		

