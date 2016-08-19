
extends Control

# member variables here, example:
# var a=2
# var b="textvar"

onready var MenuList = { "MainMenu" : get_node("ActionSelectionMainMenu"),
	"AttackMenu" : get_node("ScrollableBox/AttackMenu"),
	"MagicMenu" : get_node("ScrollableBox/MagicMenu")}
onready var currentMenu = MenuList.MainMenu
onready var currentmenupath = Array(["MainMenu"])
onready var TERRAIN = get_parent().get_node("Terrain")
onready var WORLD = get_parent()

var ActSelReq = {}

func _ready():
	act_sel_req_reset()
	set_process_input(true)

func _input(event):
	if(event.type == InputEvent.MOUSE_BUTTON and event.button_index == BUTTON_LEFT and event.is_pressed()):
		if (WORLD.get_state() == "Char_Select"):
			if(event.type == InputEvent.MOUSE_BUTTON and event.button_index == BUTTON_LEFT):
				get_tree().set_input_as_handled()
				var selectedPos = TERRAIN.global2grid_coord(event.pos)
				print(selectedPos)
				print(TERRAIN.get_terrain_map()[selectedPos])
				for Character in WORLD.get_node(WORLD.ACTIVE_PLAYER).get_children():
					if (Character.get_grid_pos() == selectedPos):
						Character.change_state("ACTIVE") 
						WORLD.ACTIVE_CHAR = Character
						WORLD.change_state("Action_Select")
		elif (WORLD.get_state()=="Action_Specifics"):
			var selectedpos = TERRAIN.global2grid_coord(event.pos)
			if (ActSelReq.flag == 1):
				get_tree().set_input_as_handled()
				if (ActSelReq.requesting_action.global_selectable_area.find(selectedpos)>-1):
					ActSelReq.flag = 2
					ActSelReq.reply = selectedpos
					update()
			elif (ActSelReq.flag == 2):
				get_tree().set_input_as_handled()
				if (selectedpos == ActSelReq.reply):
					ActSelReq.requesting_action.accept_reply(ActSelReq.reply)
	
	if(event.type == Input.is_key_pressed(KEY_ESCAPE)):
		if (WORLD.get_state()=="Action_Select" and currentMenu == MenuList["MainMenu"]):
			WORLD.change_state("Char_Select")
			get_tree().set_input_as_handled()
			
		elif (WORLD.get_state()=="Action_Select" and currentMenu != MenuList.MainMenu):
			currentmenupath.pop_back()
			menu_load(currentmenupath[currentmenupath.size()-1])
			get_tree().set_input_as_handled()
		
		elif (WORLD.get_state()=="Action_Specifics"):
			if (ActSelReq.flag == 1):
				WORLD.change_state("Action_Select")
				get_tree().set_input_as_handled()
			elif (ActSelReq.flag == 2):
				ActSelReq.flag -= 1
				ActSelReq.reply = Vector2()
				update()
				get_tree().set_input_as_handled()
		#NEED TO ADD MORE


func _draw():
	if (WORLD.get_state()=="Action_Specifics"):
		if (ActSelReq.flag > 0):
			var rectsize = Vector2(20,20)
			for tile in ActSelReq.requesting_action.global_selectable_area:
				draw_rect(Rect2(TERRAIN.grid2global_coord(tile)-rectsize/2,rectsize),Color(1,0,0,0.3))
		if (ActSelReq.flag == 2):
			var rectsize = Vector2(30,30)
			for tile in ActSelReq.requesting_action.AoE:
				draw_rect(Rect2(TERRAIN.grid2global_coord(tile+ActSelReq.reply)-rectsize/2,rectsize),Color(0,1,1,0.9))

func menu_hide():
	currentMenu.hide()

func reset():
	currentMenu.hide()
	for child in MenuList.AttackMenu.get_children():
		child.free()
	for child in MenuList.MagicMenu.get_children():
		child.free()
	currentMenu = MenuList.MainMenu

func menu_generate():
	MenuList.AttackMenu.menu_generate(get_parent().ACTIVE_CHAR)
	MenuList.MagicMenu.menu_generate(get_parent().ACTIVE_CHAR)
	

func menu_load(menuname):
	currentMenu.hide()
	currentMenu = MenuList[menuname]
	currentMenu.show()
	if currentmenupath[currentmenupath.size()-1]!=menuname:
		currentmenupath.append(menuname)

func act_sel_req_reset():
	ActSelReq.flag = 0
	ActSelReq.requesting_action = null
	ActSelReq.reply = Vector2()
	
func set_target_request(action):
	WORLD.change_state("Action_Specifics")
	ActSelReq.flag = 1
	ActSelReq.requesting_action = action
	ActSelReq.AoE = action.AoE
	update()




