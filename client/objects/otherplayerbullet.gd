extends Bullet


func _on_hitbox_body_entered(body):
	if int(body.name) == get_tree().get_network_unique_id():
		body.damage(25, name)
	Server.rpc_id(1, "destroy_bullet", name)

