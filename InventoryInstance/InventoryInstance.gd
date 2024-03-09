extends Control

var mouse_hover = false
var mouse_pos
var old_pos
var container_id
var inventory = null
var container
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_container(id):
	container_id = id

func set_inv(inv):
	self.inventory = inv
	
	$CtrlInventoryGridEx.inventory = inv.inventory_grid
	$ColorRect.size.x = 32* inv.inventory_grid.size.x - 32
	$Button.position.x = $ColorRect.size.x

func _process(delta):
	if old_pos != null && mouse_pos != null:
		self.position = old_pos + (get_viewport().get_mouse_position() - mouse_pos)

func _on_button_pressed():
	get_parent().close_inventory(self)
	pass # Replace with function body.

func _unhandled_input(event):
	if event.is_action_pressed("click"):
		
		if mouse_hover == true:
			_on_button_2_button_down()
			
	if event.is_action_released("click") && old_pos != null:
		_on_button_2_button_up()

func _on_button_2_button_down():
	
	old_pos = self.position
	mouse_pos = get_viewport().get_mouse_position()
	pass # Replace with function body.


func _on_button_2_button_up():
	old_pos = null
	mouse_pos = null
	pass # Replace with function body.


func _on_color_rect_mouse_entered():
	print("mouse over")
	mouse_hover = true
	pass # Replace with function body.


func _on_color_rect_mouse_exited():
	mouse_hover = false
	pass # Replace with function body.
