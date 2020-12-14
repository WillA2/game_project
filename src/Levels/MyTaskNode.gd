extends Node2D

class_name MyTasks

class MyTaskNode:
	var children = []
	func add_kid(node) -> void:
		children.append(node)
	
	
class MyBehaviorTree:
	var m_root
	func _init(root):
		m_root = root
	
	func run() -> bool:
		if m_root == null:
			return false
		return m_root.run()

class MySequenceNode extends MyTaskNode:
	func run() -> bool:
		for child in children:
			if child.run() == false:
				return false
		return true
		
class MySelectorNode extends MyTaskNode:
	func run() -> bool:
		for child in children:
			if child.run() == true:
				return true
		return false
