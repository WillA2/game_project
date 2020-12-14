extends KinematicBody2D

var velocity = Vector2.ZERO
var accel = Vector2.ZERO
export var force = 1
export var speed = 0
var player_pos


func _ready():
	rotation = player_pos.angle_to_point(position)
	
func _physics_process(delta: float) -> void:
	var timer = get_node("Timer")
	if (timer.get_time_left() <= 1):
		speed = 100
		rotation = velocity.angle()
	if (timer.get_time_left() <= 0.4):
		queue_free()
	velocity += attack_player(player_pos)
	position += velocity * delta
	move_and_collide(velocity * speed * delta)
	


func _on_Area2D_body_entered(body: Node) -> void:
	if body == self.get_parent().get_node("player"):
		body.killed()
	queue_free()

func attack_player(pos):
	var attack = Vector2.ZERO
	var tar = (pos - self.get_position()).normalized() * speed
	attack = (tar - velocity).normalized() * force
	return attack

