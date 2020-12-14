extends actor

var stinger = load("res://src/actors/angry_attack.tscn")
var node = load ("res://src/Levels/MyTaskNode.gd")
export var health = 200
export var detection = Vector2(500,500)
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
		
class player_in_range extends tasknodes:
	func _init(agent):
		MyAgentNode(agent)
	
	func run()->bool:
		var player_node = MyAgent.get_parent().get_node("player")
		var player_pos = player_node.get_position()
		return 	(MyAgent.get_position() + MyAgent.detection) > player_pos and (MyAgent.get_position() - MyAgent.detection) < player_pos 	

class shoot extends tasknodes:
	func _init(agent):
		MyAgentNode(agent)
	
	func run()->bool:
		var player_node = MyAgent.get_parent().get_node("player")
		var player_pos = player_node.get_position()
		var s = MyAgent.stinger.instance()
		s.global_position = MyAgent.get_position()
		s.player_pos = player_pos
		MyAgent.get_parent().add_child(s)
		return true
		
class reload extends tasknodes:
	func _init(agent, time):
		MyAgentNode(agent)
		self.time = time
	func run()->bool:
		var timer = MyAgent.get_node("Timer")
		if timer.get_time_left() <= 0.5:
			timer.stop()
			timer.set_wait_time(time)
			timer.start()
			return true
		else:
			return false
	var time
#behavior tree
func build_behavior_tree():
	var root = null
	var angrybox_behavior = node.MySequenceNode.new()
	angrybox_behavior.add_kid(player_in_range.new(self))
	angrybox_behavior.add_kid(reload.new(self,1.5))
	angrybox_behavior.add_kid(shoot.new(self))
	root = angrybox_behavior
	
	self.behavior = node.MyBehaviorTree.new(root)
	 

func _physics_process(delta: float) -> void:
	if self.behavior == null:
		self.build_behavior_tree()
	self.behavior.run()
	velocity.y += gravity * delta
	velocity.x *= 0
	velocity.y = move_and_slide(velocity*0).y


func attacked(damage: int) -> void:
	health -= damage
	if health <= 0:
		queue_free()
		

