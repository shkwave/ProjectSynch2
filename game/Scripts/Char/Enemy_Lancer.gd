
extends "res://Scripts/Char/Character.gd"

func _init():

	CLASS_TYPE = "Lancer"
	AVAIL_ACTIONS = ["Standard Attack","Sweep","Pierce","HammerDown"]
	DEAD_TEXTURE = ResourceLoader.load("res://Textures/Characters/deadplayer_20x20pxl.tex")
	TEXTURE = ResourceLoader.load("res://Textures/Characters/redplayer_20x20pxl.tex")
	MAX_HP = 4
	MAX_AP = 5
	MAX_MP = 0


func _ready():

	TEAM = "P2"
	set_grid_pos(TERRAIN.world_to_map(get_pos()))


