
extends "res://Scripts/Char/Character.gd"

func _init():

	CLASS_TYPE = "Lancer"
	
	STANDARD_ACTIONS = ["Standard Attack","Sweep"]
	AVAIL_ACTIONS = STANDARD_ACTIONS
	KILLED_Lancer_ACTIONS = ["Sweep","Pierce"]
	
	DEAD_TEXTURE = ResourceLoader.load("res://Textures/Characters/deadplayer_20x20pxl.tex")
	TEXTURE = ResourceLoader.load("res://Textures/Characters/redplayer_20x20pxl.tex")
	MAX_HP = 4
	MAX_AP = 5
	MAX_MP = 0


func _ready():

	TEAM = "P2"
	set_grid_pos(TERRAIN.world_to_map(get_pos()))


