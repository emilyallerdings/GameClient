extends CharacterBody3D

# TODO: Add descriptions for each value

@export_category("Character")
@export var base_speed : float = 3.0
@export var sprint_speed : float = 6.0
@export var crouch_speed : float = 1.0

@export var acceleration : float = 10.0
@export var jump_velocity : float = 4.5
@export var mouse_sensitivity : float = 0.1

@export_group("Nodes")
@export var HEAD : Node3D
@export var CAMERA : Camera3D
@export var CAMERA_ANIMATION : AnimationPlayer
@export var COLLISION_MESH : CollisionShape3D

@export_group("Controls")
# We are using UI controls because they are built into Godot Engine so they can be used right away
@export var JUMP : String = "jump"
@export var LEFT : String = "left"
@export var RIGHT : String = "right"
@export var FORWARD : String = "forward"
@export var BACKWARD : String = "back"
@export var PAUSE : String = "ui_cancel"
@export var CROUCH : String = "crouch"
@export var SPRINT : String = "sprint"

# Uncomment if you want full controller support
#@export var LOOK_LEFT : String
#@export var LOOK_RIGHT : String
#@export var LOOK_UP : String
#@export var LOOK_DOWN : String

@export_group("Feature Settings")
@export var immobile : bool = false
@export var jumping_enabled : bool = true
@export var in_air_momentum : bool = true
@export var motion_smoothing : bool = true
@export var sprint_enabled : bool = true
@export var crouch_enabled : bool = true
@export_enum("Hold to Crouch", "Toggle Crouch") var crouch_mode : int = 0
@export_enum("Hold to Sprint", "Toggle Sprint") var sprint_mode : int = 0
@export var dynamic_fov : bool = true
@export var continuous_jumping : bool = true
@export var view_bobbing : bool = true

# Member variables
var speed : float = base_speed
# States: normal, crouching, sprinting
var state : String = "normal"
var low_ceiling : bool = false # This is for when the cieling is too low and the player needs to crouch.

# Get the gravity from the project settings to be synced with RigidBody nodes
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity") # Don't set this as a const, see the gravity section in _physics_process
var player_id
var current_interactable = null
@onready var inventory = $Inventory

func _ready():
	$Head/Camera.current = false
	$UserInterface.hide()

	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	
	if multiplayer.get_unique_id() != player_id:
		return
	
	# Add some debug data
	$UserInterface/DebugPanel.add_property("Movement Speed", speed, 1)
	$UserInterface/DebugPanel.add_property("Velocity", get_real_velocity(), 2)
	
	# Gravity
	#gravity = ProjectSettings.get_setting("physics/3d/default_gravity") # If the gravity changes during your game, uncomment this code
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	handle_jumping()
	
	var input_dir = Vector2.ZERO
	if !immobile:
		input_dir = Input.get_vector(LEFT, RIGHT, FORWARD, BACKWARD)
	handle_movement(delta, input_dir)
	
	low_ceiling = $CrouchCeilingDetection.is_colliding()
	
	handle_state(input_dir)
	update_camera_fov()
	update_collision_scale()
	
	if view_bobbing:
		headbob_animation(input_dir)
	
	
	handle_raycast()
		

func handle_jumping():
	if jumping_enabled:
		if continuous_jumping:
			if Input.is_action_pressed(JUMP) and is_on_floor():
				velocity.y += jump_velocity
		else:
			if Input.is_action_just_pressed(JUMP) and is_on_floor():
				velocity.y += jump_velocity


func handle_movement(delta, input_dir):
	var direction = input_dir.rotated(-HEAD.rotation.y)
	direction = Vector3(direction.x, 0, direction.y)
	
	set_direction.rpc_id(1,direction)
	
	#move_and_slide()
	
	#if in_air_momentum:
	#	if is_on_floor():
	#		if motion_smoothing:
	#			velocity.x = lerp(velocity.x, direction.x * speed, acceleration * delta)
	#			velocity.z = lerp(velocity.z, direction.z * speed, acceleration * delta)
	#		else:
	#			velocity.x = direction.x * speed
	#			velocity.z = direction.z * speed
	#else:
	#	if motion_smoothing:
	#		velocity.x = lerp(velocity.x, direction.x * speed, acceleration * delta)
	#		velocity.z = lerp(velocity.z, direction.z * speed, acceleration * delta)
	#	else:
	#		velocity.x = direction.x * speed
	#		velocity.z = direction.z * speed


func handle_state(moving):
	if sprint_enabled:
		if sprint_mode == 0:
			if Input.is_action_pressed("sprint") and !Input.is_action_pressed("crouch"):
				if moving:
					if state != "sprinting":
						enter_sprint_state()
				else:
					if state == "sprinting":
						enter_normal_state()
			elif state == "sprinting":
				enter_normal_state()
		elif sprint_mode == 1:
			if moving:
				if Input.is_action_just_pressed("sprint"):
					match state:
						"normal":
							enter_sprint_state()
						"sprinting":
							enter_normal_state()
			elif state == "sprinting":
				enter_normal_state()
	
	if crouch_enabled:
		if crouch_mode == 0:
			if Input.is_action_pressed("crouch") and !Input.is_action_pressed("sprint"):
				if state != "crouching":
					enter_crouch_state()
			elif state == "crouching" and !$CrouchCeilingDetection.is_colliding():
				enter_normal_state()
		elif crouch_mode == 1:
			if Input.is_action_just_pressed("crouch"):
				match state:
					"normal":
						enter_crouch_state()
					"crouching":
						if !$CrouchCeilingDetection.is_colliding():
							enter_normal_state()


func enter_normal_state():
	#print("entering normal state")
	var prev_state = state
	state = "normal"
	speed = base_speed

func enter_crouch_state():
	#print("entering crouch state")
	var prev_state = state
	state = "crouching"
	speed = crouch_speed


func enter_sprint_state():
	#print("entering sprint state")
	var prev_state = state
	state = "sprinting"
	speed = sprint_speed


func update_camera_fov():
	if state == "sprinting":
		CAMERA.fov = lerp(CAMERA.fov, 85.0, 0.3)
	else:
		CAMERA.fov = lerp(CAMERA.fov, 75.0, 0.3)


func update_collision_scale():
	if state == "crouching": # Add your own crouch animation code
		COLLISION_MESH.scale.y = lerp(COLLISION_MESH.scale.y, 0.75, 0.2)
	else:
		COLLISION_MESH.scale.y = lerp(COLLISION_MESH.scale.y, 1.0, 0.2)


func headbob_animation(moving):
	if moving and is_on_floor():
		CAMERA_ANIMATION.play("headbob")
		CAMERA_ANIMATION.speed_scale = speed / base_speed
	else:
		CAMERA_ANIMATION.play("RESET")


func _process(delta):
	
	if multiplayer.get_unique_id() != player_id:
		return
	
	$UserInterface/DebugPanel.add_property("FPS", 1.0/delta, 0)
	$UserInterface/DebugPanel.add_property("State", state, 0)
	
	HEAD.rotation.x = clamp(HEAD.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	
	# Uncomment if you want full controller support
	#var controller_view_rotation = Input.get_vector(LOOK_LEFT, LOOK_RIGHT, LOOK_UP, LOOK_DOWN)
	#HEAD.rotation_degrees.y -= controller_view_rotation.x * 1.5
	#HEAD.rotation_degrees.x -= controller_view_rotation.y * 1.5


func _unhandled_input(event):
	
	if multiplayer.get_unique_id() != player_id:
		return
		
	if Input.is_action_just_pressed("sprint"):
		set_sprint.rpc_id(1,true)
	if Input.is_action_just_released("sprint"):
		set_sprint.rpc_id(1,false)
			
	if Input.is_action_just_pressed("crouch"):
		set_crouch.rpc_id(1,true)
	if Input.is_action_just_released("crouch"):
		set_crouch.rpc_id(1,false)
		
	if Input.is_action_just_pressed("jump"):
		set_jump.rpc_id(1,true)
	if Input.is_action_just_released("jump"):
		set_jump.rpc_id(1,false)
		
	if Input.is_action_just_pressed("interact"):
		if current_interactable:
			current_interactable.interact()
		
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		HEAD.rotation_degrees.y -= event.relative.x * mouse_sensitivity
		HEAD.rotation_degrees.x -= event.relative.y * mouse_sensitivity
	
	set_head_rot.rpc_id(1, HEAD.rotation)

func handle_raycast():
	var camera = $Head/Camera
	var viewport = get_viewport().size/2
	var from = camera.project_ray_origin(viewport)
	var to = from + camera.project_ray_normal(viewport) * 1.8
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	
	if result.has("collider"):
		
		if result.collider.has_method("interact"):
			$UserInterface/Reticle_1.dot_color = Color(0,1,0)
			$UserInterface/Reticle_1.line_color = Color(0,1,0)
			current_interactable = result.collider
		else:
			$UserInterface/Reticle_1.dot_color = Color(1,1,1)
			$UserInterface/Reticle_1.line_color = Color(1,1,1)
			current_interactable = null
	else:
		$UserInterface/Reticle_1.dot_color = Color(1,1,1)
		$UserInterface/Reticle_1.line_color = Color(1,1,1)
		current_interactable = null

@rpc("authority", "call_local", "reliable")
func create_backpack_slot_inv(id):
	$BackpackSlotInv.create_sizeless_inventory(id)
	$BackpackSlot.inventory = $BackpackSlotInv.inventory_grid

func get_backpack_slot():
	return $BackpackSlot

@rpc("authority", "call_remote", "reliable")
func set_camera_enable(b):
	$Head/Camera.current = b
	$UserInterface.show()

@rpc("authority", "call_local", "reliable")
func set_player_id(id):
	player_id = id
	if player_id == multiplayer.get_unique_id():
		ClientInfo.player = self
		ClientInfo.player_id = player_id

@rpc("any_peer", "call_remote")
func set_head_rot(rot):
	return

@rpc("any_peer", "call_remote")
func set_jump(b):
	return
	
@rpc("any_peer", "call_remote")
func set_direction(dir):
	return
	
@rpc("any_peer", "call_remote")
func set_crouch(b):
	return
	
@rpc("any_peer", "call_remote")
func set_sprint(b):
	return
