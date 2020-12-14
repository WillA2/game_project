extends KinematicBody2D


var velocity = Vector2(100, 0)
export var speed = 5
export var damage = 100
func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * speed * delta)
	
func flip(dir: int) ->void:
	if dir:
		velocity.x = abs(velocity.x) 
	else:
		velocity.x = abs(velocity.x) * -1.0
	

func get_damage() -> int:
	return damage





func _on_Area2D_body_entered(body: Node) -> void:
	if body == self.get_parent().get_node("spider") || body == self.get_parent().get_node("boss") || body == self.get_parent().get_node("angrybox"):
		body.attacked(damage)
	queue_free()
