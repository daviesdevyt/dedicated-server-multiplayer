extends Node

var coins = 0

func instance_node_at_position(node:Object, parent:Object, location:Vector2):
	var node_instance = instance_node(node, parent)
	node_instance.global_position = location
	return node_instance
	

func instance_node(node:Object, parent:Object):
	var node_instance = node.instance()
	parent.add_child(node_instance)
	return node_instance
