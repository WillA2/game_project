extends KinematicBody2D


var velocity = Vector2(100, 0)
export var speed = 1
export var damage = 10
func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * speed * delta)
	
func flip(dir: int) ->void:
	if dir:
		velocity.x *= 1.0
	else:
		velocity.x *= -1.0
	

func get_damage() -> int:
	return damage

func _on_Area2D_body_entered(body: Node) -> void:
	queue_free() #Replace with function body.
