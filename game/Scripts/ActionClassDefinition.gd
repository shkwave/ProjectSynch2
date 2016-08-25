extends Node

func createaction(ActionName,Char):
	if (ActionName == "Standard Attack"):
		return StandardAttack.new(Char)
	elif(ActionName == "Sweep"):
		return Sweep.new(Char)
	elif(ActionName == "Pierce"):
		return Pierce.new(Char)
	elif(ActionName == "HammerDown"):
		return HammerDown.new(Char)
	else:
		print(str("Error action ",ActionName," is not defined"))

#===========================================================================================
# ACTION CLASS DEFINITION
#===========================================================================================
class Action:
	extends Node
	var ROOT
	var Target
	var ExecTurn
	var Sender
	
	func _init(Char):
		# get a reference to the root node and define the sender as the char that 
		# generated this action
		Sender = Char
		ROOT = Char.get_tree().get_root()
	
	func accept_reply(reply):
		print(str("ERR: No accept_reply method is defined for selected action "))
	
	func execute():
		print(str("ERR: No execute method is defined for selected action "))

#===========================================================================================
# MOVE ACTION CLASS DEFINITION
#===========================================================================================
class MoveAction:
	extends Action
	
	var global_selectable_area
	var AoE
	var AoE_rotate
	
	func _init(Char).(Char):
		AoE_rotate = false
		AoE = Vector2Array()
		AoE.push_back(Vector2(0,0))
		ExecTurn = ROOT.get_node("globals").get_current_turn()
		global_selectable_area = Sender.get_walkable_area()
		ROOT.get_node("World/HUD").set_target_request(self)
	
	func accept_reply(reply):
		Target = reply
		ROOT.get_node("World/MessageManager").add_action(self)
		ROOT.get_node("World").change_state("Action_Execution")
	
	func execute():
		Sender.set_grid_pos(Target)


#===========================================================================================
# AttackAction template definition
#===========================================================================================
class AttackAction:
	extends Action
	
	var Damage
	var AP_cost
	var relative_selectable_area
	var global_selectable_area
	var AoE_start
	var AoE
	var AoE_rotate
	
	func _init(Char).(Char):
		AoE_rotate = false
		global_selectable_area = []
	
	func comp_global_selectable_area():
		for reltile in relative_selectable_area:
			var globtile = reltile+Sender.get_grid_pos()
			if ROOT.get_node("World/Terrain").is_available_tile(globtile):
				global_selectable_area.append(globtile)
				
	func AoE_update(testreply):
		if (AoE_rotate):
			AoE = Vector2Array()
			for i in range(AoE_start.size()):
				var tmp = AoE_start[i].rotated(Vector2(0,1).angle_to(testreply-Sender.get_grid_pos()))
				if ROOT.get_node("World/Terrain").is_available_tile(tmp+testreply):
					AoE.push_back(tmp)

#-------------------------------------------------------------------------------------------

class SimpleAttackAction:
	extends AttackAction
	
	func _init(Char).(Char):
		pass
	
	func accept_reply(reply):
		Target = Vector2Array()
		for tile in AoE:
			Target.push_back(tile+reply)
		ROOT.get_node("World/MessageManager").add_action(self)
		ROOT.get_node("World").change_state("Action_Execution")
	
	func execute():
		print(str("Attacco i personaggi che stanno qui: ",Target))


#-------------------------------------------------------------------------------------------

class StandardAttack:
	extends SimpleAttackAction
	
	func _init(Char).(Char):
		AoE = Vector2Array([Vector2(0,0)])
		ExecTurn = ROOT.get_node("globals").get_current_turn()
		relative_selectable_area = Vector2Array([Vector2(0,1),Vector2(0,-1),Vector2(1,0),Vector2(-1,0)])
		comp_global_selectable_area()
		
		ROOT.get_node("World/HUD").set_target_request(self)

#-------------------------------------------------------------------------------------------

class Sweep:
	extends SimpleAttackAction
	
	func _init(Char).(Char):
		AoE_rotate = true
		AoE_start = Vector2Array([Vector2(0,0),Vector2(-1,-1),Vector2(1,-1)])
		AoE = AoE_start
		ExecTurn = ROOT.get_node("globals").get_current_turn()
		relative_selectable_area = Vector2Array([Vector2(0,1),Vector2(0,-1),Vector2(1,0),Vector2(-1,0)])
		comp_global_selectable_area()
		
		ROOT.get_node("World/HUD").set_target_request(self)

#-------------------------------------------------------------------------------------------

class Pierce:
	extends SimpleAttackAction
	
	func _init(Char).(Char):
		AoE_rotate = true
		AoE_start = Vector2Array([Vector2(0,0),Vector2(0,1),Vector2(0,2)])
		AoE = AoE_start
		ExecTurn = ROOT.get_node("globals").get_current_turn()
		relative_selectable_area = Vector2Array([Vector2(0,1),Vector2(0,-1),Vector2(1,0),Vector2(-1,0)])
		comp_global_selectable_area()
		
		ROOT.get_node("World/HUD").set_target_request(self)

#-------------------------------------------------------------------------------------------

class HammerDown:
	extends SimpleAttackAction
	
	func _init(Char).(Char):
		AoE_rotate = true
		AoE_start = Vector2Array([Vector2(0,0),Vector2(0,1),Vector2(0,2),Vector2(-1,1),Vector2(1,1)])
		AoE = AoE_start
		ExecTurn = ROOT.get_node("globals").get_current_turn()
		relative_selectable_area = Vector2Array([Vector2(0,1),Vector2(0,-1),Vector2(1,0),Vector2(-1,0)])
		comp_global_selectable_area()
		
		ROOT.get_node("World/HUD").set_target_request(self)