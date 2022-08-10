extends Node

var spawn_points = [Vector2(271, 152), Vector2(133, 501), Vector2(756, 511), Vector2(700, 127)]
var spawn_points_clone = spawn_points.duplicate()
var taken_points = []
var obj_idx = 0
var kills = {}
var highest = 0


func _ready():
	with_multiplayerapi()

func with_multiplayerapi():
	var server = NetworkedMultiplayerENet.new()
	var err = server.create_server(4242)
	if err != OK:
		print("Unable to start server")
		return
	get_tree().network_peer = server
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	print("Server created")



func _player_connected(id):
	print("Player connected: ", id)
	rpc_id(0, "instance_player", id, choose_spawn_location())
	kills[str(id)] = 0
	

func choose_spawn_location():
	randomize()
	var point = randi()%spawn_points.size()
	var loc = spawn_points[point]
	taken_points.append(loc)
	spawn_points.remove(point)
	if spawn_points.size() <= 0:
		spawn_points = spawn_points_clone.duplicate()
		taken_points.clear()
	return loc
	
remote func instance_bullet(player_rot, player_pos):
	var player_id = get_tree().get_rpc_sender_id()
	rpc("instance_new_bullet", player_id, 'bullet' + str(player_id)+"idx" + str(obj_idx), 
	player_rot, player_pos)
	obj_idx += 1

func _player_disconnected(id):
	print("Player disconnected: ", id)
	rpc_id(0, "delete_obj", id)
	kills.erase(id)

remote func player_damaged(hp):
	var player_id = get_tree().get_rpc_sender_id()
	rpc("player_damaged", player_id, hp)

remote func player_killed(killer):
	var player_id = get_tree().get_rpc_sender_id()
	kills[killer] += 1
	if kills[killer] > highest:
		highest = kills[killer]
		rpc("update_highest", highest)
	rpc_id(int(killer), "update_kills", kills[killer])
	rpc("player_killed", player_id)

remote func respawn_player(id):
	rpc("respawn_player", id, choose_spawn_location())

remote func update_transform(position, rotation, velocity):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_unreliable("update_player_transform", player_id, position, rotation, velocity)
	
remote func destroy_bullet(bullet_name):
	rpc("delete_obj", bullet_name)
	

