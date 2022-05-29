extends Area2D


func _on_coin_body_entered(body):
	if body.is_in_group("players"):
		Server.rpc_id(1, "collect_coin", name)
