extends KinematicBody2D

var velocity = Vector2()
var speed = 200
var can_shoot = true


var bullet = preload("res://objects/playerbullet.tscn")
var hp = 100

func _physics_process(delta):
	var x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	velocity = Vector2(x, y).normalized()
	move_and_slide(velocity * speed)
	look_at(get_global_mouse_position())
	
	if can_shoot and Input.is_action_pressed("ui_select"):
		Server.rpc_id(1, "instance_bullet", rotation, $muzzle.global_position)
		can_shoot = false
		yield(get_tree().create_timer(0.3), "timeout")
		can_shoot = true

func _on_network_tick_rate_timeout():
	Server.rpc_unreliable_id(1, "update_transform", global_position, rotation_degrees, velocity)

func damage(value):
	hp -= value
	if hp <= 0:
		Server.rpc_id(1, "player_killed")
	else:
		Server.rpc_id(1, "player_damaged", hp)
		
	
	
	
