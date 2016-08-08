
extends Node2D

var ACTIVE_PLAYER
var TURN_STATE
var ACTIVE_CHAR = null


func _ready():
	ACTIVE_PLAYER = "Player1"
	TURN_STATE = "Select"
	
	# Grid of position of current obstacles and terrain properties can be initialized
	get_node("Terrain").grit_init()
	for Character in get_node("Player1").get_children():
		Character.set_pos(get_node("Terrain").grid2global_coord(Character.grid_pos))
	
	for Character in get_node("Player2").get_children():
		Character.set_pos(get_node("Terrain").grid2global_coord(Character.grid_pos))
	
	set_process_input(true)


func _input(event):
	if (TURN_STATE == "Select"):
		if(event.type == InputEvent.MOUSE_BUTTON and event.button_index == BUTTON_LEFT):
			var selectedPos = get_node("Terrain").global2grid_coord(event.pos)
			print(selectedPos)
			for Character in get_node(ACTIVE_PLAYER).get_children():
				if (Character.grid_pos == selectedPos):
					Character.change_state("active") 
					ACTIVE_CHAR = Character
					TURN_STATE = "Selected"
	
	if (TURN_STATE == "Selected"):
		if(event.type == Input.is_key_pressed(KEY_ESCAPE)):
			ACTIVE_CHAR.change_state("idle")
			TURN_STATE = "Select"
