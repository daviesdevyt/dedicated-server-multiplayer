extends Node2D

var velocity = Vector2.RIGHT
var player_rot

export var speed = 1000
export var damage = 25

func _ready():
	visible = false
	yield(get_tree(), "idle_frame")
	velocity = velocity.rotated(player_rot)
	rotation = player_rot
	visible = true

func _process(delta):
	global_position += velocity * speed * delta

func _on_timer_timeout():
	Server.rpc_id(1, "destroy_bullet", name)

func _on_hit_box_body_entered(body):
	_on_timer_timeout()
