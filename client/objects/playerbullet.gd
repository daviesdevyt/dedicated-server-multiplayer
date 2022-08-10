extends Bullet


func _on_Timer_timeout():
	Server.rpc_id(1, "destroy_bullet", name)


func _on_hitbox_body_entered(body):
	_on_Timer_timeout()
