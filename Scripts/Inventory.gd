extends Node3D

var inventory_grid = null
var inv_dict = {}
var inventory_id

var connected_item_id

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
#@rpc("authority", "call_remote", "reliable")
#func add_item(item_name, item_id, item_pos):
	#print("adding item:", item_id, " to ", self)
	#var item = inventory_grid.create_and_add_item_at(item_name, item_pos)
	#
	#if inv_dict.has(item_id):
		#print("inventory already has item")
		#return
		#
	#if item:
		#item.prev_inv = self
		#inv_dict[item_id] = item
		#item.item_id = item_id
		#item.old_pos = inventory_grid.get_item_position(item)
	#else:
		#if inventory_grid.get_item_at(item_pos).item_id == item_id:
			#item = inventory_grid.get_item_at(item_pos)
			#item.prev_inv = self
			#inv_dict[item_id] = item
			#item.item_id = item_id
			#item.old_pos = inventory_grid.get_item_position(item)
			#print("inventory already has item")
		#else:
			#print("error creating replicated item")
	#return

@rpc("any_peer", "call_remote", "reliable")
func request_move_item_same_inv(item_id, item_pos):
	return

@rpc("authority", "call_remote", "reliable")
func send_move_item_same_inv(item_id, item_pos):
	print("recieved new item pos")
	
	if inventory_grid.get_item_position(inv_dict[item_id]) == item_pos:
		return
		
	inv_dict[item_id].old_pos = item_pos
	inventory_grid.move_item_to(inv_dict[item_id], item_pos)

@rpc("authority", "call_local", "reliable")
func create_sizeless_inventory(id):
	inventory_grid = Inventory.new()
	inventory_grid.item_protoset = ResourceLoader.load("res://ItemProtoset.tres")
	
	inventory_grid.connected_inventory = self
	
	inventory_id = id
	
	inventory_grid.item_modified.connect(item_modified)
	inventory_grid.item_removed.connect(item_removed)
	inventory_grid.item_added.connect(item_added)
	
@rpc("authority", "call_local", "reliable")
func create_inventory(width,height, id):
	print("creating inventory...")
	inventory_grid = InventoryGrid.new()
	inventory_grid.item_protoset = ResourceLoader.load("res://ItemProtoset.tres")
	inventory_grid.size.x = width
	inventory_grid.size.y = height
	
	inventory_grid.connected_inventory = self
	
	inventory_id = id
	
	inventory_grid.item_modified.connect(item_modified)
	inventory_grid.item_removed.connect(item_removed)
	inventory_grid.item_added.connect(item_added)

@rpc("authority", "call_remote", "reliable")
func replicate_item(item_id, item_name):
	print("replicating item to: ", self)
	var item = inventory_grid.create_and_add_item(item_name)
	if item:
		item.prev_inv = self
		inv_dict[item_id] = item
		item.item_id = item_id
		if inventory_grid is InventoryGrid:
			item.old_pos = inventory_grid.get_item_position(item)
	else:
		print("error creating replicated item")
	return
	
#@rpc("authority", "call_remote", "reliable")
func add_item_at(item_id, item_name, item_pos):
	
	print("adding item at ", item_pos, ", inv size: ", inventory_grid.size)
	var item = inventory_grid.create_and_add_item_at(item_name, item_pos)
	
	if item:
		item.prev_inv = self
		inv_dict[item_id] = item
		item.item_id = item_id
		item.old_pos = inventory_grid.get_item_position(item)
	else:
		print("error adding item at ", item_pos)
	return
	
func add_item_c(item_id, item_name):
	
	print("adding item")
	var item = inventory_grid.create_and_add_item(item_name)
	
	if item:
		item.prev_inv = self
		inv_dict[item_id] = item
		item.item_id = item_id
		item.old_pos = Vector2(0,0)
	else:
		print("error adding item ")
	return

@rpc("authority", "call_remote", "reliable")
func remove_item(item_id):
	if inv_dict.has(item_id):
		print("removing item:", item_id, " from ", self)
		inventory_grid.remove_item(inv_dict[item_id])
	return

@rpc("authority", "call_remote", "reliable")
func add_item(item_name, item_id, item_pos):
	if inv_dict.has(item_id):
		var item = inv_dict[item_id]
		item.prev_inv = self
		print("2, ", item.prev_inv)
		if inventory_grid is InventoryGrid:
			item.old_pos = inventory_grid.get_item_position(item)
		else:
			item.old_pos = Vector2(0,0)
		print("3, ", item.prev_inv)
		return

	if inventory_grid is InventoryGrid:
		print("trying to add item at ", item_pos)
		add_item_at(item_id, item_name, item_pos)
	else:
		add_item_c(item_id, item_name)
	return

func item_removed(item):
	print("item removed")
	inv_dict.erase(item.item_id)
	item.just_added = true
	print("4, ", item.prev_inv)
	print(item)
	return

func item_added(item):
	print("item added")
	
	print("5, ", item.prev_inv)
	print(item)
	if item.prev_inv == null:
		print("prev_inv is null")
		return
		
	if item.prev_inv == self:
		print("prev_inv is self???")
		return
	
	if item.prev_inv != self:
		print("prev_inv is different")
		
		
		print (item.prev_inv.inventory_grid)
		
		#if item.prev_inv.inventory_grid is InventoryGrid:
		await item.item_dropped_sig
		
		var item_pos = null
		if inventory_grid is InventoryGrid:
			item_pos = inventory_grid.get_item_position(item)
		
		print("item:", item.item_id, " transfered from ", item.prev_inv, " to ", self)
		print("from: ", item.old_pos, " to ", item_pos , " dropped at ", item.new_pos )
		print("sending transfer request")
		
		inv_dict[item.item_id] = item
		
		Server.request_transfer_item.rpc_id(1, item.item_id, 
			item.prev_inv.inventory_id, inventory_id, item_pos)
		print("1, ", item.prev_inv)
		return

func item_modified(item):
	print("item:", item, " modified in ", self)
	
	if !(inventory_grid is InventoryGrid):
		return
	
	if item.prev_inv == self:
		print("same inventory...")
		if item.old_pos == inventory_grid.get_item_position(item):
			print("item didnt change position.")
			return
		else:
			print("item changed position...")
			item.old_pos = inventory_grid.get_item_position(item)
			
			print(inv_dict.find_key(item))
			print(inv_dict)
			
			
			request_move_item_same_inv.rpc_id(1,
				 inv_dict.find_key(item),
				 inventory_grid.get_item_position(item))
			return
	
	#var item_new_inventory = item.get_inventory()
	#
	#if item.prev_inv == null:
		#return 
	#
	#if item.prev_inv.inventory_grid != inventory_grid:
		#
		#print("item:", item.item_id, " transfered from ", item.prev_inv, " to ", self)
		#
		#item.old_pos = inventory_grid.get_item_position(item)
		#
		#print("sending transfer request")
		#
		#Server.request_transfer_item.rpc_id(1, item.item_id, 
		#item.prev_inv.inventory_id, inventory_id, inventory_grid.get_item_position(item))
		#
		#inv_dict[item.item_id] = item
		#inv_dict.prev_inv = self
		#
		#pass
	#else:
		#if item.old_pos != inventory_grid.get_item_position(item):
			#print("item:", item.item_id, " moved in ", item.prev_inv)
			#
			#print(self, ", ", item.old_pos, ", ", inventory_grid.get_item_position(item))
			#item.old_pos = inventory_grid.get_item_position(item)
			#request_move_item_same_inv.rpc_id(1, inv_dict.find_key(item), inventory_grid.get_item_position(item))
		#pass
	return
	
@rpc("authority", "call_local", "reliable")
func connect_item(item_id, inv_id):
	inv_dict[item_id].set_property("connected_inv", inv_id)
	return
