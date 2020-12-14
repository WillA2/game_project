extends KinematicBody2D


	
func _physics_process(delta: float) -> void:
	var velocity = Vector2.ZERO
	move_and_collide(velocity * 0)
	
