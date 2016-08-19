extends Node

class Action:
	extends Node
	var Target
	var ExecTurn
	var Sender
	

class AttackAction:
	extends Action
	
	var Damage
	var Type
	var Precision
	var relative_selectable_area
	var global_selectable_area
	
	func setup(node):
		Sender = node
		ExecTurn = node.get_node("/root/globals").get_current_turn()
		node.get_node("/root/World/HUD").set_target_request(self)

class MoveAction:
	extends Action
	
	var global_selectable_area
	var AoE
	
	func setup(Char):
		Sender = Char
		AoE = Vector2Array()
		AoE.push_back(Vector2(0,0))
		ExecTurn = Char.get_node("/root/globals").get_current_turn()
		global_selectable_area = Char.get_walkable_area()
		Char.get_node("/root/World/HUD").set_target_request(self)
	
	func accept_reply(reply):
		self.Target = reply
		Sender.get_node("/root/World/MessageManager").add_action(self)
		Sender.get_node("/root/World").change_state("Action_Execution")
	
	func execute():
		Sender.set_grid_pos(Target)