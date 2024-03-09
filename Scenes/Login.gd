extends Control

var IP_ADDRESS = "174.0.52.23"
var PORT = 1421

# Called when the node enters the scene tree for the first time.
const STASH_MAIN = preload("res://Scenes/StashMain.tscn")

func _ready():
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)

func _process(delta):
	pass

func connected_to_server():
	$Panel.hide()
	#$Panel2.show()
	#StashServer.send_server_player_info.rpc_id(1, $Panel/VBoxContainer/TextEdit.text)
	StashServer.player_name = $Panel/VBoxContainer/TextEdit.text
	get_tree().change_scene_to_packed(STASH_MAIN)
	print("connected to server")
	
func connection_failed():
	print("connection failed")
	
func _on_button_pressed():
	start_connection()
	
func start_connection():
	if $Panel/VBoxContainer/CheckButton.button_pressed == true:
		IP_ADDRESS = "127.0.0.1"
		print("local")
		
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
	
