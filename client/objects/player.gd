extends KinematicBody2D


var velocity = Vector2()
var speed = 200
var can_shoot = true
var hp = 100 setget set_health

func set_health(value):
	hp = value

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

func _on_Timer_timeout():
	Server.rpc_unreliable_id(1, "update_transform", global_position, rotation_degrees, velocity)

func damage(value, bullet_name):
	hp -= value
	if hp <= 0:
		
		var killer = ""
		for i in range(len(bullet_name)-6):
			if bullet_name[6+i].is_valid_integer():
				killer += bullet_name[6+i]
			else: break
		Server.rpc_id(1, "player_killed", killer)
	else:
		Server.rpc_id(1, "player_damaged", hp)
