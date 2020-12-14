extends actor
var bullet = preload ("res://src/actors/Bullet.tscn")
var cat = load ("res://assets/cat.png")
var lose_screen = preload("res://src/actors/game_over_screen.tscn")
var flipped = false
onready var sprite = $player
export var stomp: = 600.0
func _physics_process(delta: float) -> void:
	
	var jump_count = 0
	var interrupt_jump: = Input.is_action_just_released("jump") and velocity.y < 0.0
	var direction: = get_direction()
	if Input.is_action_just_pressed("move_left"):
		get_node( "player" ).set_flip_h( true )
		flipped = true
		
	if Input.is_action_just_pressed("move_right"):
		get_node( "player" ).set_flip_h(false)
		flipped = false
		
	if Input.is_action_just_pressed("ui_select"):
		shoot()
	 
	if Input.is_action_just_pressed("exit"):
		close_everything()
	velocity = calc_move_vel(velocity, direction, speed, interrupt_jump)
	velocity = move_and_slide(velocity, Vector2.UP)

#func _on_detect_enemy_area_entered(area: Area2D) -> void:
	#velocity = calculate_stomp_velcoity(velocity, stomp)
	


func close_everything():
	var parent = self.get_parent()
	for child in parent.get_children():
		if (child != self):
			child.free()
	get_tree().quit()
	
#direction
func get_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"), 
		-1.0 if Input.is_action_just_pressed("jump") and is_on_floor() else 0.0
		)
#calculations
func calc_move_vel(
	linear_velocity: Vector2,
	direction: Vector2,
	speed: Vector2,
	jump_interrupted: bool
) -> Vector2:
	var new_vel: = linear_velocity
	new_vel.x = speed.x * direction.x
	new_vel.y += gravity * get_physics_process_delta_time()
	if direction.y == -1.0:
		new_vel.y = speed.y * direction.y
	if jump_interrupted:
		new_vel.y = 0.0
	return new_vel
	

func shoot() -> void:
	var b = bullet.instance()
	if flipped:
		b.flip(0)
		b.global_position = get_node("p2").global_position
	else:
		b.flip(1)
		b.global_position = get_node("point").global_position
	get_parent().add_child(b)

	
func play_lose():
	var b = lose_screen.instance()
	b.global_position = self.get_position()
	get_parent().add_child(b)
	
func _on_detect_enemy_body_entered(body: Node) -> void:
	set_process(false)
	hide()
	play_lose()
	#print("x")


func killed():
	set_process(false)
	hide()
	play_lose()
	#print("x")
