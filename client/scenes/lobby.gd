extends Control


func _on_join_pressed():
	Server.join_server()
	$join.disabled = true
