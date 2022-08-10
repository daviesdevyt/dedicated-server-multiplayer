extends Node

var player = preload("res://objects/player.tscn")
var otherplayer = preload("res://objects/otherplayer.tscn")
var map = preload("res://scenes/map.tscn")

var enemy_bullet = preload("res://objects/otherplayerbullet.tscn")
var bullet = preload("res://objects/playerbullet.tscn")

func _ready():
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("server_disconnected", self, '_server_disconnected')
	get_tree().connect("connection_failed", self, "connection_failed")

func join_server():
	var client = NetworkedMultiplayerENet.new()
	var err = client.create_client("159.223.209.73", 4242)
	if err != OK:
		print("unable_to_connect")
		return
	get_tree().network_peer = client

func connection_failed():
	get_node("/root/lobby/join").disabled = false
	print("Connection failed")

func _server_disconnected():
	get_node("/root/lobby").show()
	print("server disconnected")

func _connected_to_server():
	get_node("/root/lobby").hide()
	print("Connected to server")
	var scene = map.instance()
	scene.name = "Map"
	get_tree().root.add_child_below_node(Global, scene)

remote func instance_player(id, location):
	var p = player if get_tree().get_network_unique_id() == id else otherplayer
	var player_instance = Global.instance_node(p , Nodes, location)
	player_instance.name = str(id)
	if get_tree().get_network_unique_id() == id:
		for i in get_tree().get_network_connected_peers():
			if i != 1:
				instance_player(i, location)

remote func instance_new_bullet(id, bullet_name, rot, pos):
	var b = bullet if get_tree().get_network_unique_id() == id else enemy_bullet
	var bullet_instance = Global.instance_node(b, Nodes, pos)
	bullet_instance.player_rot = rot
	bullet_instance.name = bullet_name

remote func player_damaged(id, hp):
	var p = Nodes.get_node(str(id))
	if get_tree().get_network_unique_id() != id:
		p.hp = hp
	var prev_modulate = p.modulate
	p.modulate = Color(5,5,5,1)
	yield(get_tree().create_timer(0.1), "timeout")
	p.modulate = prev_modulate

remote func player_killed(id):
	var killed_player = Nodes.get_node(str(id))
	killed_player.get_node("shape").disabled = true
	killed_player.set_physics_process(false)
	killed_player.hide()
	if id == get_tree().get_network_unique_id():
		get_node("../Map/failed").show()
		yield(get_tree().create_timer(3), "timeout")
		get_node("../Map/failed").hide()
		rpc_id(1, "respawn_player", get_tree().get_network_unique_id())
	
remote func respawn_player(id, location):
	if Nodes.has_node(str(id)):
		var player = Nodes.get_node(str(id))
		player.global_position = location
		player.get_node("shape").disabled = false
		player.set_physics_process(true)
		player.hp = 100
		player.show()

remote func update_highest(kills):
	get_node("../Map").update_highest(kills)

remote func update_kills(kills):
	get_node("../Map").update_kills(kills)

remote func update_player_transform(id, position, rotation, velocity):
	if get_tree().get_network_unique_id() != id:
		Nodes.get_node(str(id)).update_transform(position, rotation, velocity)

remote func delete_obj(id):
	if Nodes.has_node(str(id)):
		Nodes.get_node(str(id)).queue_free()


