
extends Panel


@onready var h_box_container = $HBoxContainer
@onready var ctrl_inv = $HBoxContainer/CtrlInventoryGridEx

@onready var ctrl_item_slot_ex = $HBoxContainer/CenterContainer/InvSlot/CtrlItemSlotEx

func get_backpack_slot():
	return ctrl_item_slot_ex

# Called when the node enters the scene tree for the first time.
func _ready():
	ctrl_inv.hide()
	custom_minimum_size = h_box_container.size
	custom_minimum_size.x = 800
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if ctrl_item_slot_ex.item_slot:
		if ctrl_item_slot_ex.item_slot.item == null:
			if ctrl_inv.visible:
				ctrl_inv._refresh_field_background_grid()
				ctrl_inv.hide()
				
				
	#h_box_container.custom_minimum_size = custom_minimum_size
	pass


func _on_h_box_container_resized():
	custom_minimum_size = h_box_container.size
	custom_minimum_size.x = 800
	pass # Replace with function body.



func _on_ctrl_item_slot_ex_on_item_dropped(item):
	
	var inv_containers = ClientInfo.inventory_containers
	var con_inventory = null
	
	for inventory in inv_containers.get_children():
		if inventory.inventory_id == item.get_property("connected_inv"):
			con_inventory = inventory

	
	if con_inventory:
		
		#var ctrl_inv = CtrlInventoryGridEx.new()
		#ctrl_inv.field_style = preload("res://InventoryInstance/inventory_instance.tres")
		
		h_box_container.add_child(ctrl_inv)
		
		ctrl_inv.inventory = con_inventory.inventory_grid
		ctrl_inv.custom_minimum_size = con_inventory.inventory_grid.size * 48
		
		ctrl_inv._refresh_field_background_grid()
		ctrl_item_slot_ex._refresh()
		ctrl_inv.show()
		
	pass # Replace with function body.
