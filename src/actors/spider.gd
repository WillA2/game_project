extends actor

var bullet = preload ("res://src/actors/Bullet.tscn")
var node = load ("res://src/Levels/MyTaskNode.gd")
var timer
export var health = 200

var fall = 0
var move = 0
export var detection = 200
export var ground_speed = 150
export var chase_multiplier = 1.014

var behavior = null

class tasknodes extends MyTasks:
	var MyAgent
	func MyAgentNode(agent):
		MyAgent = agent
		
#sample to copy
class sample extends tasknodes:
	func _init(agent):
		MyAgentNode(agent)
	
	func run()->bool:
		var variable
		return false
		
class is_agent_under extends tasknodes:
	func _init(agent):
		MyAgentNode(agent)
		
	func run()->bool:
		var player_node = MyAgent.get_parent().get_node("player")
		var player_pos = player_node.get_position()
		if (MyAgent.get_position().x > player_pos.x - 10 
		and MyAgent.get_position().x < player_pos.x + 10
		and MyAgent.get_position().y + 100 < player_pos.y):
			return true
		else: 
			return false
		

class fall_down extends tasknodes:
	func _init(agent):
		MyAgentNode(agent)
	
	func run()->bool:
		MyAgent.fall = 1
		return true

class has_landed extends tasknodes:
	func _init(agent):
		MyAgentNode(agent)
	
	func run()->bool:
		return MyAgent.is_on_floor()

class chase_close_player extends tasknodes:
	func _init(agent):
		MyAgentNode(agent)
	
	func run()->bool:
		var player_node = MyAgent.get_parent().get_node("player")
		var player_pos = player_node.get_position()
		if MyAgent.velocity.x == 0:
			MyAgent.velocity.x = MyAgent.ground_speed
		MyAgent.move = 1
		if (MyAgent.get_position().x + MyAgent.detection  > player_pos.x 
		and MyAgent.get_position().x - MyAgent.detection < player_pos.x  
		and MyAgent.get_position().y + 10 > player_pos.y
		and MyAgent.get_position().y - 10 < player_pos.y
		and player_node.is_visible()):
			var follow_force = player_pos.x - MyAgent.get_position().x
			if follow_force < 0:
				MyAgent.velocity.x = -abs(MyAgent.velocity.x) * MyAgent.chase_multiplier
				MyAgent.get_node("spidaeh 200 pr").set_flip_h(false)
			else:
				MyAgent.velocity.x = abs(MyAgent.velocity.x) * MyAgent.chase_multiplier
				MyAgent.get_node("spidaeh 200 pr").set_flip_h(true)
			return true
		else:
			if abs(MyAgent.velocity.x) != MyAgent.ground_speed:
				MyAgent.velocity.x = MyAgent.ground_speed
			return false
		
#behavior tree
func build_behavior_tree():
	var root = null
	var angry_man_behavior = node.MySelectorNode.new()
	var fall_attack = node.MySequenceNode.new()
	var chase = node.MySequenceNode.new()
	var detect_agent = is_agent_under.new(self)
	var falldown = fall_down.new(self)
	var is_grounded = has_landed.new(self)
	var detect_and_chase = chase_close_player.new(self)
	angry_man_behavior.add_kid(fall_attack)
	angry_man_behavior.add_kid(chase)
	fall_attack.add_kid(detect_agent)
	fall_attack.add_kid(falldown)
	chase.add_kid(is_grounded)
	chase.add_kid(detect_and_chase)
	
	root = angry_man_behavior
	
	self.behavior = node.MyBehaviorTree.new(root)
	 

func _ready() -> void:
	velocity.x = -speed.x
	get_node("Timer").set_wait_time(1.5)

func _physics_process(delta: float) -> void:
	if self.behavior == null:
		self.build_behavior_tree()
	self.behavior.run()
	
	velocity.y += gravity * delta*fall
	velocity.x *= move
	if is_on_wall():
		velocity.x *= -1.0
	velocity.y = move_and_slide(velocity, Vector2.UP).y


func attacked(damage: int) -> void:
	health -= damage
	if health <= 0:
		queue_free()
		

