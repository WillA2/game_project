extends KinematicBody2D

class_name actor

export var speed: = Vector2(400.0, 800.0)
export var gravity: = 2000

var velocity: = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
	var velocity: = Vector2(300,0)


