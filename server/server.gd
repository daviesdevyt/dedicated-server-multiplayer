extends Node

var spawn_points = [Vector2(130, 130), Vector2(133, 501), Vector2(840, 511), Vector2(700, 127)]
var spawn_points_clone = spawn_points.duplicate()
var taken_points = []
var obj_name_idx = 0
var total_kills = 0

func _ready():
	with_multiplayer_api()

func with_multiplayer_api():
	var server = NetworkedMultiplayerENet.new()
	var err = server.create_server(4242)
	if err != OK:
		print("Unable to start server")
		set_process(false)
		return
	get_tree().network_peer = server
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	print("Server created")

func with_websocket():
	var server = WebSocketServer.new()
	var err = server.listen(4242, PoolStringArray(), true)
	if err != OK:
		print("Unable to start server")
		set_process(false)
		return
	get_tree().network_peer = server
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	print("Server created")


func _player_connected(id):
	randomize()
	print("Player connected: ", id)
	rpc_id(0, "instance_player", id, choose_spawn_location())

func choose_spawn_location():
	var point = randi()%spawn_points.size()
	var loc = spawn_points[point]
	taken_points.append(loc)
	spawn_points.remove(point)
	if spawn_points.size() <= 0:
		spawn_points = spawn_points_clone.duplicate()
		taken_points.clear()
	return loc

remote func respawn_player(id):
	rpc("respawn_player", id, choose_spawn_location())

func _player_disconnected(id):
	print("Player disconnected: ", id)
	rpc_id(0, "delete_obj", id)
 
remote func update_transform(position, rotation, velocity):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_unreliable("update_player_transform", player_id, position, rotation, velocity)

remote func instance_bullet(player_rot, player_pos):
	var player_id = get_tree().get_rpc_sender_id()
	rpc("instance_new_bullet", player_id, 'bullet' + str(player_id) + str(obj_name_idx), player_rot, player_pos)
	obj_name_idx += 1

remote func destroy_bullet(bullet_name):
	rpc("delete_obj", bullet_name)

remote func player_killed():
	var player_id = get_tree().get_rpc_sender_id()
	rpc("player_killed", player_id)

remote func player_damaged(hp):
	var player_id = get_tree().get_rpc_sender_id()
	rpc("player_damaged", player_id, hp)

remote func collect_coin(coin):
	rpc("collected_coin", coin, get_tree().get_rpc_sender_id())

func _exit_tree():
	rpc("shut_down")

func _unhandled_key_input(event):
	if event.is_action_released("ui_select"):
		rpc("shut_down")
	
