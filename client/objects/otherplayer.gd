extends KinematicBody2D


onready var tween = $Tween
var speed = 200
var puppet_pos = Vector2()
var puppet_rot = 0
var hp = 100 setget set_health
var puppet_vel = Vector2()

func set_health(value):
	hp = value

func _physics_process(delta):
	rotation_degrees = lerp(rotation_degrees, puppet_rot, 15*delta)

func update_transform(_puppet_pos, _puppet_rot, _puppet_vel):
	new_puppet_pos(_puppet_pos)
	puppet_rot = _puppet_rot
	puppet_vel = _puppet_vel

func new_puppet_pos(value):
	puppet_pos = value
	tween.interpolate_property(self, "global_position", global_position, puppet_pos, 0.05)
	tween.start()
