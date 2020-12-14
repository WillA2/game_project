extends KinematicBody2D

var velocity = Vector2.ZERO
export var force = 1
export var speed = 10
var origin = Vector2.ZERO

	
func _physics_process(delta: float) -> void:
	velocity += (self.get_position() - origin).normalized()
	var timer = get_node("Timer")
	if timer.get_time_left() <= 0.2:
		queue_free()
	move_and_collide(velocity * speed * delta)
	


func _on_Area2D_body_entered(body: Node) -> void:
	if body == self.get_parent().get_node("player"):
		body.killed()
	queue_free() 
