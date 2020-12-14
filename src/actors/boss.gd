extends actor
var node = load ("res://src/Levels/MyTaskNode.gd")
var stinger = preload("res://src/actors/stinger.tscn")
var leaf = preload ("res://src/actors/leaf.tscn")
var arrow = preload("res://src/actors/arrow.tscn")
var behavior = null
var movement_speed = 0
export var health = 600
export var detection = 900
var circle_angle = 0
var max_arrow = 0
var in_strike = 0
var striking = 0
var attack_coord = Vector2.ZERO
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
		
class phase1_hp extends tasknodes:
	func _init(agent):
		MyAgentNode(agent)
	
	func run()->bool:
		return MyAgent.health > 400
		
class is_player_in_range extends tasknodes:
	func _init(agent):
		MyAgentNode(agent)
	
	func run()->bool:
		var player_node = MyAgent.get_parent().get_node("player")
		var player_pos = player_node.get_position()
		if (MyAgent.get_position().x + MyAgent.detection > player_pos.x and 
		MyAgent.get_position().x - MyAgent.detection < player_pos.x and
		MyAgent.get_position().y + MyAgent.detection > player_pos.y and 
		MyAgent.get_position().y - MyAgent.detection < player_pos.y):
			return true
		else:
			return false

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
	
class summon_stingers extends tasknodes:
	func _init(agent):
		MyAgentNode(agent)
	
	func run()->bool:
		var player_node = MyAgent.get_parent().get_node("player")
		var player_pos = player_node.get_position()
		var s = MyAgent.stinger.instance()
		var angle = randi()%360
		var circle = Vector2.ZERO
		circle.x = player_pos.x + 300 * cos(angle)
		circle.y = player_pos.y + 300 * sin(angle)
		s.global_position = circle
		s.player_pos = player_pos
		MyAgent.get_parent().add_child(s)
		return true

class phase2_hp extends tasknodes:
	func _init(agent):
		MyAgentNode(agent)
	
	func run()->bool:
		return MyAgent.health > 200 && MyAgent.health <= 400

class phase2_transform extends tasknodes:
	func _init(agent):
		MyAgentNode(agent)
	
	func run()->bool:
		if (MyAgent.get_node("phase2").is_visible()):
			return true
		MyAgent.get_node("cataBox").disabled = true
		MyAgent.get_node("boss").hide()
		
		MyAgent.get_node("phase2").show()
		MyAgent.get_node("cocoonBox").disabled = false
		return true

			
class leaf_attack extends tasknodes:
	func _init(agent):
		MyAgentNode(agent)
	
	func run()->bool:
		var circle = Vector2.ZERO
		var attack = MyAgent.leaf.instance()
		circle.x = MyAgent.get_position().x + 50 * cos(MyAgent.circle_angle)
		circle.y = (MyAgent.get_position().y - 150) + 50 * sin(MyAgent.circle_angle)
		MyAgent.circle_angle += 0.5
		attack.global_position = circle
		attack.origin.y = MyAgent.get_position().y - 150
		attack.origin.x = MyAgent.get_position().x
		MyAgent.get_parent().add_child(attack)
		return true


class phase3_hp extends tasknodes:
	func _init(agent):
		MyAgentNode(agent)
	
	func run()->bool:
		var variable
		return MyAgent.health > 0 && MyAgent.health <= 200
		
class phase3_transform extends tasknodes:
	func _init(agent):
		MyAgentNode(agent)
	
	func run()->bool:
		if (MyAgent.get_node("phase3").is_visible() or MyAgent.in_strike == 1):
			return true
		var timer = MyAgent.get_node("Timer")
		timer.stop()
		MyAgent.get_node("cocoonBox").disabled = true
		MyAgent.get_node("phase2").hide()
		
		MyAgent.get_node("phase3").show()
		MyAgent.get_node("butBox").disabled = false
		MyAgent.set_collision_mask(0)
		return true

class fly_offscreen extends tasknodes:
	func _init(agent):
		MyAgentNode(agent)
	
	func run()->bool:
		if  MyAgent.striking == 1:
			return true
		var player_node = MyAgent.get_parent().get_node("player")
		var player_pos = player_node.get_position()
		MyAgent.movement_speed = 50
		MyAgent.velocity.y += -200
		if abs(MyAgent.get_position().y - player_pos.y) > 1000:
			return true
		else:
			return false

class strike_transform extends tasknodes:
	func _init(agent):
		MyAgentNode(agent)
	
	func run()->bool:
		if (MyAgent.get_node("strike").is_visible()):
			return true
		MyAgent.get_node("butBox").disabled = true
		MyAgent.get_node("phase3").hide()
		
		MyAgent.get_node("strike").show()
		MyAgent.get_node("strikeBox").disabled = false
		
		MyAgent.get_node("a").get_node("hitbox").disabled = false
		MyAgent.get_node("b").get_node("hitbox").disabled = true
		MyAgent.in_strike = 1
		MyAgent.set_collision_mask(0)
		return true

class strike_wait extends tasknodes:
	func _init(agent):
		MyAgentNode(agent)
		
	func send_arrow(pos):
		if MyAgent.max_arrow >= 1:
			return
		
		var s = MyAgent.arrow.instance()
		s.global_position = MyAgent.get_position()
		s.player_pos = pos
		MyAgent.get_parent().add_child(s)
		MyAgent.max_arrow = 1
		
	func run()->bool:
		if MyAgent.striking == 1:
			return true
		MyAgent.movement_speed = 0
		var timer = MyAgent.get_node("Timer")
		if timer.is_stopped():
			timer.start(1.5)
		if timer.get_time_left() <= 0.5:
			MyAgent.velocity = Vector2.ZERO
			timer.stop()
			return true
		else:
			if MyAgent.attack_coord == Vector2.ZERO:
				var player_node = MyAgent.get_parent().get_node("player")
				var player_pos = player_node.get_position()
				MyAgent.attack_coord = player_pos
				MyAgent.rotation = MyAgent.attack_coord.angle_to_point(MyAgent.position)
			send_arrow(MyAgent.attack_coord)
			return false
			
class strike extends tasknodes:
	func _init(agent):
		MyAgentNode(agent)
	
	func attack_player(pos):
		var attack = Vector2.ZERO
		var tar = (pos - MyAgent.get_position()).normalized() * MyAgent.speed
		attack = (tar - MyAgent.velocity).normalized() * 1
		return attack
	
	func run()->bool:
		MyAgent.movement_speed = 100
		MyAgent.striking = 1
		MyAgent.velocity += attack_player(MyAgent.attack_coord)
	#	
		
		if MyAgent.get_position().y > MyAgent.attack_coord.y :
			MyAgent.striking = 0
			MyAgent.movement_speed = 0
			MyAgent.in_strike = 0
			MyAgent.velocity = Vector2.ZERO
			MyAgent.attack_coord = Vector2.ZERO
			return true
		return false

class unstrike_transform extends tasknodes:
	func _init(agent):
		MyAgentNode(agent)
	
	func run()->bool:
		MyAgent.get_node("strikeBox").disabled = true
		MyAgent.get_node("strike").hide()
		
		MyAgent.get_node("phase3").show()
		MyAgent.get_node("butBox").disabled = false
		
		MyAgent.get_node("a").get_node("hitbox").disabled = true
		MyAgent.get_node("b").get_node("hitbox").disabled = false
		MyAgent.set_collision_mask(0)
		MyAgent.rotation = 0		
		
		return true				
			
func build_behavior_tree():
	var root = null
	var boss_behavior = node.MySelectorNode.new()
	var phase1 = node.MySequenceNode.new()
	var phase2 = node.MySequenceNode.new()
	var phase3 = node.MySequenceNode.new()
	var fly_attack = node.MySequenceNode.new()
	boss_behavior.add_kid(phase1)
	boss_behavior.add_kid(phase2)
	boss_behavior.add_kid(phase3)
	phase1.add_kid(phase1_hp.new(self))
	phase1.add_kid(is_player_in_range.new(self))
	phase1.add_kid(reload.new(self,1.5))
	phase1.add_kid(summon_stingers.new(self))
	phase2.add_kid(phase2_hp.new(self))
	phase2.add_kid(phase2_transform.new(self))
	phase2.add_kid(reload.new(self,0.6))
	phase2.add_kid(leaf_attack.new(self))
	phase3.add_kid(phase3_hp.new(self))
	phase3.add_kid(phase3_transform.new(self))
	fly_attack.add_kid(fly_offscreen.new(self))
	fly_attack.add_kid(strike_transform.new(self))
	fly_attack.add_kid(strike_wait.new(self))
	fly_attack.add_kid(strike.new(self))
	fly_attack.add_kid(unstrike_transform.new(self))
	phase3.add_kid(fly_attack)
	root = boss_behavior
	self.behavior = node.MyBehaviorTree.new(root)

func _ready():
	self.get_node("Control/health_bar").max_value = health
	
func _physics_process(delta: float) -> void:
	if self.behavior == null:
		self.build_behavior_tree()
	self.behavior.run()
	position += velocity * delta * striking
	velocity = move_and_slide(velocity * movement_speed * delta)



func attacked(damage: int) -> void:
	health -= damage
	#print(health)
	self.get_node("Control/health_bar").value = health
	if health == 0:
		queue_free()
		


func _on_Area2D_body_entered(body: Node) -> void:
	if body == self.get_parent().get_node("player"):
		body.killed()



func _on_b_body_entered(body: Node) -> void:
	if body == self.get_parent().get_node("player"):
		body.killed()
