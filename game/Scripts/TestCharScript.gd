
extends Node2D

var TERRAIN 

var IDLE_TEXTURE = ResourceLoader.load("res://Textures/Characters/blueplayer.tex")
var ACTIVE_TEXTURE = ResourceLoader.load("res://Textures/Characters/cyanplayer.tex")

var CHAR_STATE
var CHAR_POSSIBLE_STATES = ["IDLE","ACTIVE"]
var CHAR_AVAIL_ACTIONS = ["Move","Attack","Magic","Use"]
var ATTACK_OPTIONS = ["Attack","Attack2","Attack3","Attack4","Attack5","Attack6"]
var MAGIC_OPTIONS = ["Magic1","Magic2"]
var grid_pos setget set_grid_pos,get_grid_pos
var stamina = 4

func _ready():
	TERRAIN = get_tree().get_root().get_node("World/Terrain")
	get_node("Sprite").set_texture(IDLE_TEXTURE)
	CHAR_STATE = "IDLE"
	#set_process(true)

#-------------------------------------------------------------------------------------------------------
# FINITE STATE MACHINE HANDLING - CHANGE STATE HANDLING
#-------------------------------------------------------------------------------------------------------

func change_state(newstate):
	# check that newstate is in the list of possible states
	if (CHAR_POSSIBLE_STATES.find(newstate)>-1):
		self.on_state_exit(self.CHAR_STATE)
		
		print("Changing state of ",self.get_name()," from ",self.CHAR_STATE," to ",newstate)
		CHAR_STATE = newstate
		
		self.on_state_enter(newstate)
	else:
		print("Error in state handling, state ",newstate," does not exist.")
		self.get_tree().quit()


func on_state_enter(newstate):
	# Method to be called when the FSM enters in a new state
	
	if (newstate == "ACTIVE"):
		self.get_node("Sprite").set_texture(ACTIVE_TEXTURE)
		
	if (newstate == "IDLE"):
		self.get_node("Sprite").set_texture(IDLE_TEXTURE)


func on_state_exit(oldstate):
	pass
	

#-------------------------------------------------------------------------------------------------------
# SET AND GET GRID POSITION
#-------------------------------------------------------------------------------------------------------

func get_grid_pos():
	return grid_pos

func set_grid_pos(new_pos):
	grid_pos = new_pos
	self.set_pos(TERRAIN.grid2global_coord(grid_pos))

#-------------------------------------------------------------------------------------------------------
# MENU CREATION
#-------------------------------------------------------------------------------------------------------

func get_attack_options():
	return ATTACK_OPTIONS

func get_magic_options():
	return MAGIC_OPTIONS

#-------------------------------------------------------------------------------------------------------
# COMPUTATION OF WALKABLE AREA
#-------------------------------------------------------------------------------------------------------

func get_walkable_area():
	var walkable = []
	var terrain_map = TERRAIN.get_terrain_map()
	var walkmap = get_node("/root/globals").matrix_init(TERRAIN.nrow,TERRAIN.ncol,self.stamina+1)
	walkmap[get_grid_pos()] = 0
	walkable = []
	walkable.append(get_grid_pos())
	var curind = 0
	var newcoord = Vector2()
	var newval = null
	
	# Neighbouring cells [North, West, South, East]
	var neighbours = Vector2Array([Vector2(-1,0),Vector2(0,-1),Vector2(1,0),Vector2(0,1)])
	
	while (curind<walkable.size()):
		if (walkmap[walkable[curind]]<self.stamina):
			for neighbour in neighbours:
				newcoord = walkable[curind]+neighbour
				if (newcoord.x>=0 and newcoord.x<=TERRAIN.nrow-1 and newcoord.y>=0 and newcoord.y<=TERRAIN.ncol-1):
					newval = walkmap[walkable[curind]]+terrain_map[newcoord]
					if (walkmap[newcoord]>newval):
						walkmap[newcoord]=newval
						if (newval<=self.stamina):
							var tobeadded = true
							for i in range(curind+1,walkable.size()):
								if (walkable[i]==newcoord): 
									tobeadded=false
							if tobeadded:
								walkable.append(newcoord)
		curind +=1
		
	curind = 0
	while (curind<walkable.size()):
		var parsingindex = curind+1
		while (parsingindex<walkable.size()):
			if (walkable[parsingindex]==walkable[curind]):
				walkable.erase(parsingindex)
			else:
				parsingindex +=1
		curind +=1
	walkable.pop_front()
	return walkable