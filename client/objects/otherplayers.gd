extends KinematicBody2D

onready var tween = $tween
var speed = 200
var puppet_pos = Vector2()
var puppet_rot = 0
var puppet_vel = Vector2()
var hp = 100 setget new_hp

func new_hp(new_value):
	hp = new_value

func update_transform(_puppet_pos, _puppet_rot, _puppet_vel):
	new_puppet_pos(_puppet_pos)
	puppet_rot = _puppet_rot
	puppet_vel = _puppet_vel

func _physics_process(delta):
	rotation_degrees = lerp(rotation_degrees, puppet_rot, 15*delta)
	if not tween.is_active():
		move_and_slide(puppet_vel*speed)
	
func new_puppet_pos(value):
	puppet_pos = value
	
	tween.interpolate_property(self, "global_position", global_position, puppet_pos, 0.05)
	tween.start()
	
	
	
