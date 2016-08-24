extends Node

class Action:
	extends Node
	var ROOT
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
		ROOT = Char.get_tree().get_root()
		Sender = Char
		AoE = Vector2Array()
		AoE.push_back(Vector2(0,0))
		ExecTurn = ROOT.get_node("globals").get_current_turn()
		ExecTurn = ExecTurn + ExecTurn%2
		global_selectable_area = Char.get_walkable_area()
		ROOT.get_node("World/HUD").set_target_request(self)
	
	func accept_reply(reply):
		Target = reply
		ROOT.get_node("World/MessageManager").add_action(self)
		ROOT.get_node("World").change_state("Action_Execution")
	
	func execute():
		Sender.set_grid_pos(Target)