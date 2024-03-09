extends Control

var IP_ADDRESS = "174.0.52.23"
var PORT = 1420

const PLAYER_INFO = preload("res://Scenes/player_info.tscn")

@onready var game = $Game
var isready = false
var player_lobby_list = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	Server.client = self
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func start_connection():
	if $Panel/VBoxContainer/CheckButton.button_pressed == true:
		IP_ADDRESS = "127.0.0.1"
		print("local")
		
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
	
func add_player(id, player_name, isready):
	var new_player_info = PLAYER_INFO.instantiate()
	new_player_info.setID(id)
	new_player_info.setName(player_name)
	new_player_info.setReady(isready)
	player_lobby_list[id] = new_player_info
	$Panel2/MarginContainer/PlayerList.add_child(new_player_info)
	pass
	
func remove_player(id):
	print("remove player")
	var to_remove
	if !player_lobby_list.has(id):
		return
		
	to_remove = player_lobby_list[id]	
	player_lobby_list.erase(id)
	to_remove.queue_free()

func connected_to_server():
	$Panel.hide()
	$Panel2.show()
	Server.send_server_player_info.rpc_id(1, $Panel/VBoxContainer/TextEdit.text)
	print("connected to server")
	
func connection_failed():
	print("connection failed")

func _on_button_pressed():
	start_connection()
	pass # Replace with function body.

func _on_ready_button_pressed():
	if isready:
		$Panel2/ReadyButton.text = "READY"
		isready = false
	else:
		$Panel2/ReadyButton.text = "UNREADY"
		isready = true
		
	Server.send_ready.rpc_id(1, isready)
	
func set_player_ready(id, isready):
	print("here")
	player_lobby_list[id].setReady(isready)
	pass # Replace with function body.
	
func start_game():
	game.start_game()
	$Panel.hide()
	$Panel2.hide()
