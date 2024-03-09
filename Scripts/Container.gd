extends StaticBody3D

var inventory_manager = null
@onready var inventory = $Inventory

# Called when the node enters the scene tree for the first time.
func _ready():
	inventory_manager = get_parent().get_parent().get_node("InventoryManager")
	#inventory_grid.create_and_add_item("TestItem3")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func interact():
	if inventory_manager:
		#TODO MAKE AUTHORITY CHECK FOR OPEN BEFORE OPENING
		inventory_manager.open_inventory(inventory)
	return
