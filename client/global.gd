extends Node



func instance_node(node, parent, location):
	var node_instance = node.instance()
	node_instance.global_position = location
	parent.add_child(node_instance)
	return node_instance
