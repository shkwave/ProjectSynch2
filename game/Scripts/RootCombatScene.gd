
extends Node2D

var ACTIVE_PLAYER
var INACTIVE_PLAYER
var TURN_STATE
var ACTIVE_CHAR
var GAME_POSSIBLE_STATES = ["Char_Select","Action_Select","Action_Specifics","Action_Execution"]

onready var TERRAIN = get_node("Terrain")
onready var HUD = get_node("HUD")
onready var MENU =  get_node("HUD/MenuSystem")
onready var CAMERA = get_node("Camera2D")

var WORLD_SIZE = Vector2(2048,2000)

var show_state_change = true

func _ready():
	ACTIVE_PLAYER = "Player1"
	INACTIVE_PLAYER = "Player2"
	ACTIVE_CHAR = get_node(ACTIVE_PLAYER).get_next_active_char()
	ACTIVE_CHAR.change_state("ACTIVE")
	TURN_STATE = "Char_Select"
	change_state("Action_Select")

func change_state(newstate):
	if (GAME_POSSIBLE_STATES.find(newstate)==-1):
		# HANDLE ERROR in State definition
		print("Error in state handling, state ",newstate," does not exist.")
		self.get_tree().quit()
	else:
		self.on_state_exit(self.TURN_STATE)
		
		if show_state_change:
			print("Changing state of TURN_STATE from ",self.TURN_STATE," to ",newstate)
		
		#Special cases 
		if ((self.TURN_STATE == "Char_Select" or self.TURN_STATE == "Action_Execution") and newstate == "Action_Select"):
			CAMERA.move_camera_to(ACTIVE_CHAR.get_pos())
			yield(CAMERA,"camera_moved")
			MENU.menu_generate()
			MENU.menu_load("MainMenu")
		if (self.TURN_STATE == "Action_Specifics" and newstate == "Action_Select"):
			MENU.menu_load(MENU.currentmenupath[MENU.currentmenupath.size()-1])
		
		self.TURN_STATE = newstate
		
		self.on_state_enter(newstate)


func on_state_exit(state):
	if (state == "Action_Select"):
		MENU.menu_hide()
	if (state == "Action_Specifics"):
		HUD.act_sel_req_reset()
		HUD.set_size(Vector2(1,1))
		HUD.update()

func on_state_enter(state):
	if (state == "Char_Select"):
		# Not yet sure when the camera should be moved
		MENU.reset()
#		CAMERA.move_camera_to(ACTIVE_CHAR.get_pos())
#		yield(CAMERA,"camera_moved")
	if (state == "Action_Select"):
		# Not yet sure when the camera should be moved
		MENU.set_pos(ACTIVE_CHAR.get_pos())
		if ACTIVE_CHAR.get_AP() == 0 and MENU.actions_are_available(): 
			# if AP == 0 and the char hasn't got any free actions continue 
			# with the turn without opening the menu
			change_state("Action_Execution")
	if (state == "Action_Specifics"):
		HUD.set_size(WORLD_SIZE)
	if (state == "Action_Execution"):
		get_node("MessageManager").process()
		globals.next_turn_start()
		if ACTIVE_PLAYER == "Player1":
			ACTIVE_PLAYER = "Player2"
			INACTIVE_PLAYER = "Player1"
		elif ACTIVE_PLAYER == "Player2":
			ACTIVE_PLAYER = "Player1"
			INACTIVE_PLAYER = "Player2"
		
		if (check_win_condition()):
			#Check_win_condition checks if every char of a player are dead
			#if this is the case, the next scene is loaded however, the next bit
			#of code is executed even if the change scene happens inside check_win_condition
			#therefore this if block was necessary to avoid an infinite loop inside get_next_active_char()
			if not ACTIVE_CHAR.CHAR_STATE == "DEAD":
				ACTIVE_CHAR.change_state("IDLE")
			# Start next turn, set next char to active
			print("inizio turno #",globals.get_current_turn())
			ACTIVE_CHAR = get_node(ACTIVE_PLAYER).get_next_active_char()
			ACTIVE_CHAR.change_state("ACTIVE")
			# Should the state change to Char_Select or Action_Select?
			change_state("Action_Select")

func get_state():
	return TURN_STATE

func check_win_condition():
	# Check if one player has all of it chars dead, in this case the game is finished
	var still_alive
	var value = true
	for P in ["Player1","Player2"]:
		still_alive = false
		for char in get_node(P).get_children():
			if char.CHAR_STATE != "DEAD":
				still_alive = true
				break
		if (not still_alive):
			print(P, " loses!")
			globals.currentTurn = 1
			get_tree().reload_current_scene()
			value = false
	return value