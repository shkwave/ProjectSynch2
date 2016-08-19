
extends Node2D

var ACTIVE_PLAYER
var TURN_STATE
var ACTIVE_CHAR = null
var GAME_POSSIBLE_STATES = ["Char_Select","Action_Select","Action_Specifics","Action_Execution"]

onready var TERRAIN = get_node("Terrain")
onready var MENU =  get_node("HUD")

func _ready():
	ACTIVE_PLAYER = "Player1"
	TURN_STATE = "Char_Select"

func change_state(newstate):
	if (GAME_POSSIBLE_STATES.find(newstate)==-1):
		# HANDLE ERROR in State definition
		print("Error in state handling, state ",newstate," does not exist.")
		self.get_tree().quit()
	else:
		self.on_state_exit(self.TURN_STATE)
		
		print("Changing state of TURN_STATE from ",self.TURN_STATE," to ",newstate)
		
		#Special cases 
		if (self.TURN_STATE == "Char_Select" and newstate == "Action_Select"):
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
		MENU.act_sel_req_reset()
		MENU.update()

func on_state_enter(state):
	if (state == "Char_Select"):
		ACTIVE_CHAR.change_state("IDLE")
		ACTIVE_CHAR = null
		MENU.reset()
	if (state == "Action_Execution"):
		get_node("MessageManager").process()
		if ACTIVE_PLAYER == "Player1":
			ACTIVE_PLAYER = "Player2"
		elif ACTIVE_PLAYER == "Player2":
			ACTIVE_PLAYER = "Player1"
		get_node("/root/globals").currentTurn += 1
		print(get_node("/root/globals").currentTurn)
		change_state("Char_Select")

func get_state():
	return TURN_STATE
