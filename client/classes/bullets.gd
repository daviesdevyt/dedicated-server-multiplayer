extends Node2D
class_name Bullet


var velocity = Vector2.RIGHT
var player_rot

export var speed = 1000

func _ready():
	visible = false
	yield(get_tree(), "idle_frame")
	velocity = velocity.rotated(player_rot)
	rotation = player_rot
	visible = true


func _process(delta):
	global_position += velocity * speed * delta
