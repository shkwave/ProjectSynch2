
extends Node2D

var grid_pos 
var CHAR_STATE
var IDLE_TEXTURE = ResourceLoader.load("res://Textures/Characters/blueplayer.tex")
var ACTIVE_TEXTURE = ResourceLoader.load("res://Textures/Characters/cyanplayer.tex")

func _ready():
	CHAR_STATE = "idle"
	grid_pos = Vector2(1,1)
	set_process(true)

func change_state(newstate):
	
	if (newstate == "active"):
		self.get_node("Sprite").set_texture(ACTIVE_TEXTURE)
		
	if (newstate == "idle"):
		self.get_node("Sprite").set_texture(IDLE_TEXTURE)
	
	print("Changing state of ",self.get_name()," from ",self.CHAR_STATE," to ",newstate)
	CHAR_STATE = newstate


