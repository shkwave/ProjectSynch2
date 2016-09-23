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

signal win_condition_checked


func _ready():
	ACTIVE_PLAYER = "Player1"
	INACTIVE_PLAYER = "Player2"
	ACTIVE_CHAR = get_node(ACTIVE_PLAYER).get_next_active_char()
	ACTIVE_CHAR.change_state("ACTIVE")
	TURN_STATE = "Char_Select"
	CAMERA.move_camera_to(ACTIVE_CHAR.get_pos())
	change_state("Char_Select")

func change_state(newstate):
	if (GAME_POSSIBLE_STATES.find(newstate)==-1):
		# HANDLE ERROR in State definition
		print("Error in state handling, state ",newstate," does not exist.")
		self.get_tree().quit()
	else:
		self.on_state_exit(self.TURN_STATE)
		
		print("Changing state of TURN_STATE from ",self.TURN_STATE," to ",newstate)
		
		#Special cases 
		if ((self.TURN_STATE == "Char_Select" or self.TURN_STATE == "Action_Execution")  and newstate == "Action_Select"):
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
		#CAMERA.move_camera_to(ACTIVE_CHAR.get_pos())
		MENU.reset()
	if (state == "Action_Select"):
		#CAMERA.move_camera_to(ACTIVE_CHAR.get_pos())
		MENU.set_pos(ACTIVE_CHAR.get_pos())
		if ACTIVE_CHAR.get_AP() == 0 :
			change_state("Action_Execution")
	if (state == "Action_Specifics"):
		HUD.set_size(WORLD_SIZE)
	if (state == "Action_Execution"):
		get_node("MessageManager").process()
		globals.currentTurn += 1
		if ACTIVE_PLAYER == "Player1":
			ACTIVE_PLAYER = "Player2"
			INACTIVE_PLAYER = "Player1"
		elif ACTIVE_PLAYER == "Player2":
			ACTIVE_PLAYER = "Player1"
			INACTIVE_PLAYER = "Player2"
		if not ACTIVE_CHAR.CHAR_STATE=="DEAD":
			ACTIVE_CHAR.change_state("IDLE")
		
		var flag = check_win_condition()
		if (flag):
			ACTIVE_CHAR = get_node(ACTIVE_PLAYER).get_next_active_char()
			ACTIVE_CHAR.change_state("ACTIVE")
			print("inizio turno #", globals.get_current_turn())
			change_state("Char_Select")

func get_state():
	return TURN_STATE

func check_win_condition():
	var still_alive
	var value = true
	for P in ["Player1","Player2"]:
		still_alive = false
		print(P)
		for char in get_node(P).get_children():
			if char.CHAR_STATE != "DEAD":
				still_alive = true
				print(char.get_name())
		if (not still_alive):
			print(P, " loses!")
			globals.currentTurn = 1
			get_tree().reload_current_scene()
			value = false
	return value