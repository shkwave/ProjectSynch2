
extends Control

onready var TERRAIN = get_parent().get_node("Terrain")
onready var WORLD = get_parent()
onready var MENU = get_node("MenuSystem")
onready var DRAWNODE = get_node("DrawingBoard")

var ActSelReq = {}

func _ready():
	act_sel_req_reset()
	set_process_unhandled_input(true)
	set_process_input(true)

func _unhandled_input(event):
	if(event.type == InputEvent.MOUSE_BUTTON and event.button_index == BUTTON_LEFT and event.is_pressed()):
		if (WORLD.get_state() == "Char_Select"):
			get_tree().set_input_as_handled()
			var selected_pos = TERRAIN.world_to_map(get_global_mouse_pos())
			if selected_pos == WORLD.ACTIVE_CHAR.get_grid_pos():
				WORLD.change_state("Action_Select")
	
	if(event.is_action_pressed("ui_cancel")):
		if (WORLD.get_state()=="Action_Select" and MENU.currentMenu == MENU.MenuList["MainMenu"]):
			WORLD.change_state("Char_Select")
			get_tree().set_input_as_handled()
			
		elif (WORLD.get_state()=="Action_Select" and MENU.currentMenu != MENU.MenuList["MainMenu"]):
			MENU.currentmenupath.pop_back()
			MENU.menu_load(MENU.currentmenupath[MENU.currentmenupath.size()-1])
			get_tree().set_input_as_handled()
		
		elif (WORLD.get_state() == "Action_Specifics"):
			if (ActSelReq.flag == 1):
				WORLD.change_state("Action_Select")
				get_tree().set_input_as_handled()
			elif (ActSelReq.flag == 2):
				ActSelReq.flag -= 1
				ActSelReq.reply = Vector2()
				DRAWNODE.update()
				get_tree().set_input_as_handled()
		#NEED TO ADD MORE

func _input(event):
	if(event.type == InputEvent.MOUSE_BUTTON and event.button_index == BUTTON_LEFT and event.is_pressed()):
		if (WORLD.get_state()=="Action_Specifics"):
			var selected_pos = TERRAIN.world_to_map(get_global_mouse_pos())
			if (ActSelReq.flag == 1):
				get_tree().set_input_as_handled()
				if (ActSelReq.requesting_action.global_selectable_area.find(selected_pos)>-1):
					ActSelReq.flag = 2
					ActSelReq.reply = selected_pos
					DRAWNODE.update()
			elif (ActSelReq.flag == 2):
				get_tree().set_input_as_handled()
				if (selected_pos == ActSelReq.reply):
					ActSelReq.requesting_action.accept_reply(ActSelReq.reply)
					set_process(false)
				elif (ActSelReq.requesting_action.global_selectable_area.find(selected_pos)>-1):
					ActSelReq.reply = selected_pos
					DRAWNODE.update()

func _process(delta):
	var selected_pos = TERRAIN.world_to_map(get_global_mouse_pos())
	ActSelReq.draw_temp = false
	if ActSelReq.requesting_action.global_selectable_area.find(selected_pos)>-1:
		ActSelReq.draw_temp = true
		ActSelReq.temp_reply = selected_pos
	DRAWNODE.update()
#
#func _draw():
# OLD _DRAW function has been moved inside Drawing Board so that the HUD
# and the selectable areas etc. can be drawn on different levels 

func act_sel_req_reset():
	ActSelReq.flag = 0
	ActSelReq.requesting_action = null
	ActSelReq.draw_temp = false
	ActSelReq.reply = Vector2()
	ActSelReq.temp_reply = Vector2()
	set_process(false)
	
func set_target_request(action):
	WORLD.change_state("Action_Specifics")
	ActSelReq.flag = 1
	ActSelReq.requesting_action = action
	set_process(true)
	DRAWNODE.update()




