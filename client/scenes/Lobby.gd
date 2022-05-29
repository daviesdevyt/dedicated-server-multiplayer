extends Control


func _on_join_pressed():
	hide()
	Server.join_server()
	
	
