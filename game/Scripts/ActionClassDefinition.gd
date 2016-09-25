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
		print(str("Error action ", ActionName, " is not defined"))

#===========================================================================================
# ACTION CLASS DEFINITION
#===========================================================================================
class Action:
	extends Node
	var ROOT
	var Target
	var ExecTurn
	var Sender
	var AP_cost
	
	func _init(Char):
		#get a reference to the root node
		ROOT = Char.get_tree().get_root()
		#define the sender as the char that generated this action
		Sender = Char
		ExecTurn = 0
	
	func accept_reply(reply):
		print(str("ERR: No accept_reply method is defined for selected action."))
	
	func send_action():
		#ROOT.get_node("World/MessageManager").add_action(self)
		#Sender.reduce_AP(AP_cost)
		#self.execute()
		#Get back to main menu and allow selection of another action
		ROOT.get_node("World/HUD/MenuSystem").reset()
		ROOT.get_node("World/HUD/MenuSystem").menu_generate()
		ROOT.get_node("World/HUD/MenuSystem").menu_load("MainMenu")

		ROOT.get_node("World").change_state("Action_Select")
		
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
	var temp
	
	func _init(Char).(Char):
		AoE_rotate = false
		AoE = Vector2Array()
		AoE.push_back(Vector2(0,0))
		ExecTurn = ROOT.get_node("globals").get_current_turn()
		temp = Sender.get_walkable_area()
		global_selectable_area = temp.cell
		ROOT.get_node("World/HUD").set_target_request(self)
	
	func accept_reply(reply):
		Target = reply
		self.execute()
		for i in range(global_selectable_area.size()):
			if (global_selectable_area[i] == reply):
				AP_cost = temp.AP_cost[i]
		Sender.reduce_AP(AP_cost)
		#print(AP_cost)
		#print(Sender.AP)
		ROOT.get_node("World/HUD/MenuSystem").reset()
		ROOT.get_node("World/HUD/MenuSystem").menu_generate()
		ROOT.get_node("World/HUD/MenuSystem").menu_load("MainMenu")
		
		ROOT.get_node("World").change_state("Action_Select")
		#ROOT.get_node("World/MessageManager").add_action(self)
		#ROOT.get_node("World").change_state("Action_Execution")

	func execute():
		Sender.set_grid_pos(Target)


#===========================================================================================
# AttackAction template definition
#===========================================================================================
class AttackAction:
	extends Action
	
	var Damage
	var relative_selectable_area
	var global_selectable_area
	var Target_must_be_free
	var AoE_start
	var AoE
	var AoE_rotate
	
	func _init(Char).(Char):
		AoE_rotate = false
		Target_must_be_free = false
		global_selectable_area = []
	
	func comp_global_selectable_area():
		for reltile in relative_selectable_area:
			var globtile = reltile+Sender.get_grid_pos()
			if ROOT.get_node("World/Terrain").is_available(globtile):
				global_selectable_area.append(globtile)
	
	func setup():
		comp_global_selectable_area()
		ExecTurn += ROOT.get_node("globals").get_current_turn()
		ROOT.get_node("World/HUD").set_target_request(self)
	
	func AoE_update(testreply):
		if (AoE_rotate):
			AoE = Vector2Array()
			var rel_pos = testreply-Sender.get_grid_pos()
			for i in range(AoE_start.size()):
				var valuetorotate = AoE_start[i]+Vector2(0,1)*rel_pos.length()
				var tmp
				if(rel_pos[0]== 0 and rel_pos[1] > 0):
					tmp = valuetorotate
				elif(rel_pos[0]>0 and rel_pos[1]==0):
					tmp = Vector2(valuetorotate[1],-valuetorotate[0])
				elif(rel_pos[0]== 0 and rel_pos[1] <0):
					tmp = -valuetorotate
				elif(rel_pos[0]<0 and rel_pos[1] == 0):
					tmp = Vector2(-valuetorotate[1], valuetorotate[0])
				else:
					tmp = valuetorotate.rotated(Vector2(0,1).angle_to(testreply-Sender.get_grid_pos()))
				if ROOT.get_node("World/Terrain").is_available(tmp+Sender.get_grid_pos()):
					AoE.push_back(tmp-rel_pos)

#-------------------------------------------------------------------------------------------

class SimpleAttackAction:

	extends AttackAction
	
	func _init(Char).(Char):
		pass
	
	func accept_reply(reply):
		Target = Vector2Array()
		for tile in AoE:
			Target.push_back(tile+reply)
		execute()
	
	func execute():
		for char in ROOT.get_tree().get_nodes_in_group("Characters"):
			for tile in Target:
				if tile == char.get_grid_pos():
					#print(str(char.get_name()," has been attacked"))
					#print(str("starting at ",char.get_HP()))
					char.modify_HP(-Damage,Sender)
					#print(str("Now HP at ",char.get_HP()))
		Sender.reduce_AP(AP_cost)
		ROOT.get_node("World").change_state("Action_Execution")

#-------------------------------------------------------------------------------------------

class StandardAttack:

	extends SimpleAttackAction
	
	func _init(Char).(Char):
		Damage = 1
		AP_cost = 0
		AoE = Vector2Array([Vector2(0,0)])
		relative_selectable_area = Vector2Array([Vector2(0,1),Vector2(0,-1),Vector2(1,0),Vector2(-1,0)])

#-------------------------------------------------------------------------------------------

class Sweep:

	extends SimpleAttackAction
	
	func _init(Char).(Char):
		Damage = 1
		AP_cost = 3
		AoE_rotate = true
		AoE_start = Vector2Array([Vector2(0,0),Vector2(-1,-1),Vector2(1,-1)])
		AoE = AoE_start
		relative_selectable_area = Vector2Array([Vector2(0,1),Vector2(0,-1),Vector2(1,0),Vector2(-1,0)])

#-------------------------------------------------------------------------------------------

class Pierce:

	extends AttackAction
	
	func _init(Char).(Char):
		Damage = 2
		AP_cost = 3
		AoE_rotate = true
		Target_must_be_free = true
		AoE_start = Vector2Array([Vector2(0,-3),Vector2(0,-2),Vector2(0,-1),Vector2(0,0)])
		AoE = AoE_start
		ExecTurn = ROOT.get_node("globals").get_current_turn()
		relative_selectable_area = Vector2Array([Vector2(0,4),Vector2(0,-4),Vector2(4,0),Vector2(-4,0)])
		
	func comp_global_selectable_area():
		for reltile in relative_selectable_area:
			var globtile = reltile+Sender.get_grid_pos()
			if ROOT.get_node("World/Terrain").is_free(globtile):
				global_selectable_area.append(globtile)
	
	func accept_reply(reply):
		Target = reply
		execute()
	
	func execute():
		for char in ROOT.get_tree().get_nodes_in_group("Characters"):
			for tile in AoE:
				if tile + Target == char.get_grid_pos():
					char.modify_HP(-Damage,Sender)
		Sender.reduce_AP(AP_cost)
		Sender.set_grid_pos(Target)
		ROOT.get_node("World").change_state("Action_Execution")
#-------------------------------------------------------------------------------------------

class HammerDown:
	extends SimpleAttackAction
	
	func _init(Char).(Char):
		Damage = 4
		AP_cost = 3
		AoE_rotate = true
		AoE_start = Vector2Array([Vector2(0,0),Vector2(0,1),Vector2(0,2),Vector2(-1,1),Vector2(1,1)])
		AoE = AoE_start
		relative_selectable_area = Vector2Array([Vector2(0,1),Vector2(0,-1),Vector2(1,0),Vector2(-1,0)])
