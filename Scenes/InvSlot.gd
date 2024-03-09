extends Control

@onready var ctrl_item_slot_ex = $CtrlItemSlotEx
#@onready var inventory_grid = $CtrlItemSlotEx/InventoryGrid
#@onready var item_slot = $CtrlItemSlotEx/ItemSlot

# Called when the node enters the scene tree for the first time.
func _ready():
	ctrl_item_slot_ex.on_item_dropped.connect(on_item_dropped)
	pass # Replace with function body.

func get_item_size(item):
	var item_width: int = item.get_property("width", 1)
	var item_height: int = item.get_property("height", 1)
	return Vector2(item_width, item_height)
	
func on_item_dropped(item):
	print("item equipped")
	return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_ctrl_item_slot_ex_resized():
	#ctrl_item_slot_ex.icon_scaling = Vector2(0.2,0.2)
	pass # Replace with function body.
