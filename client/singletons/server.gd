extends Node

var client

var game_name = ProjectSettings.get("application/config/name")
var player = preload("res://objects/player.tscn")
var otherplayer = preload("res://objects/otherplayers.tscn")
var enemy_bullet = preload("res://objects/otherplayerbullet.tscn")
var bullet = preload("res://objects/playerbullet.tscn")
var map = preload("res://scenes/map1.tscn")

func _ready():
	set_process(false)
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("server_disconnected", self, '_server_disconnected')
	get_tree().connect("connection_failed", self, "connection_failed")
	

#func _process(delta):
#	client.poll()

#func join_server():
#	client = WebSocketClient.new()
#	set_process(true)
#	var err = client.connect_to_url("127.0.0.1:4242", PoolStringArray(), true)
#	if err != OK:
#		get_node("/root/game/debug").text += "\nUnable to connect"
#		print("unable_to_connect")
#		set_process(false)
#		return
#	get_tree().network_peer = client
#	return true

func join_server():
	var client = NetworkedMultiplayerENet.new()
#	var err = client.create_client("146.190.26.45", 4242)
	var err = client.create_client("127.0.0.1", 4242)
	if err != OK:
		print("unable_to_connect")
		return
	get_tree().network_peer = client
	return true

func connection_failed():
	print("Connection failed")
	

func _server_disconnected():
	print("server disconnected")

func _connected_to_server():
	print("Connected to server")
	var scene = map.instance()
	scene.name = "Map"
	get_tree().root.add_child_below_node(Global, scene)

remote func instance_player(id, loc):
	randomize()
	_instance_player(id, loc)

remote func delete_obj(id):
	if PersistentNodes.has_node(str(id)):
		PersistentNodes.get_node(str(id)).queue_free()

remote func collected_coin(coin, collector):
	if get_node("../Map/coins").has_node(coin):
		get_node("../Map/coins").get_node(coin).queue_free()
		if collector == get_tree().get_network_unique_id():
			Global.coins += 1


func _instance_player(id, location):
	var player_instance = Global.instance_node_at_position(player if get_tree().get_network_unique_id() == id else otherplayer, PersistentNodes, location)
	player_instance.name = str(id)
	if get_tree().get_network_unique_id() == id:
		for i in get_tree().get_network_connected_peers():
			if i != 1:
				instance_player(i, location)

remote func update_player_transform(id, position, rotation, velocity):
	if get_tree().get_network_unique_id() != id:
		PersistentNodes.get_node(str(id)).update_transform(position, rotation, velocity)

remote func instance_new_bullet(id, bullet_name, rot, pos):
	var bullet_instance = Global.instance_node_at_position(bullet if get_tree().get_network_unique_id() == id else enemy_bullet, 
	PersistentNodes, 
	pos)
	bullet_instance.player_rot = rot
	bullet_instance.name = bullet_name

remote func player_killed(id):
	var killed_player = PersistentNodes.get_node(str(id))
	killed_player.get_node("shape").disabled = true
	killed_player.set_physics_process(false)
	killed_player.hide()
	if id == get_tree().get_network_unique_id():
		get_node("../Map/failed").show()
		yield(get_tree().create_timer(3), "timeout")
		get_node("../Map/failed").hide()
		rpc_id(1, "respawn_player", get_tree().get_network_unique_id())

remote func respawn_player(id, location):
	if PersistentNodes.has_node(str(id)):
		var player = PersistentNodes.get_node(str(id))
		player.global_position = location
		player.get_node("shape").disabled = false
		player.set_physics_process(true)
		player.hp = 100
		player.show()
		

remote func player_damaged(id, hp):
	var p = PersistentNodes.get_node(str(id))
	if get_tree().get_network_unique_id() != id:
		p.hp = hp
	var prev_modulate = p.modulate
	p.modulate = Color(5,5,5,1)
	yield(get_tree().create_timer(0.1), "timeout")
	p.modulate = prev_modulate
	

remote func shut_down():
	get_tree().quit()
