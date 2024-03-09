extends Node

var client = null

@rpc("any_peer")
func send_server_player_info(name):
	return

@rpc("any_peer")
func send_ready(ready):
	return
	
@rpc("authority")
func create_player(id, player_name, isready):
	client.add_player(id, player_name, isready)
	return
	
@rpc("authority")
func remove_player(id):
	client.remove_player(id)
	return
	
@rpc("authority")
func send_client_ready(id, isready):
	client.set_player_ready(id, isready)
	return
	
@rpc("authority")
func send_client_start_game():
	client.start_game()
	return

@rpc("any_peer", "reliable")
func request_transfer_item(item_id, inv1_id, inv2_id, new_pos):
	#print(item_id, ", ", inv1_id, ", ", inv2_id, ", ", new_pos)
	return
