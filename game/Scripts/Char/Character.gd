
extends Node2D

var _CHAR_STATES = ["IDLE", "ACTIVE", "DEAD"]
var CHAR_STATE

var TERRAIN
var GRID_POS

var TEAM
var CLASS_TYPE
var TEXTURE
var DEAD_TEXTURE
var AVAIL_ACTIONS
var AP
var HP
var MP
var MAX_AP
var MAX_HP
var MAX_MP

var show_state_change = false

func _init():
	# Set current state to idle
	CHAR_STATE = "IDLE"


func _ready():
	# get the terrain node from the tree
	TERRAIN = get_tree().get_root().get_node("World/Terrain")
	add_to_group("Characters")

	# initialize AP, HP and MP at their maximum values
	AP = MAX_AP
	HP = MAX_HP
	MP = MAX_MP


func change_state(newstate):
	# check that newstate is in the list of possible states
	if _CHAR_STATES.find(newstate)==-1:
		# HANDLE ERROR in State definition
		print("Error in state handling, state ",newstate," does not exist.")
		self.get_tree().quit()
	else:
		self.on_state_exit(self.CHAR_STATE)
		
		if show_state_change:
			print("Changing state of ",self.get_name()," from ",self.CHAR_STATE," to ",newstate)
		CHAR_STATE = newstate

		self.on_state_enter(newstate)


func on_state_enter(newstate):
	# Method to be called when the FSM enters in a new state
	if (newstate == "ACTIVE"):
		pass
	if (newstate == "IDLE"):
		self.reset_status()
	if (newstate == "DEAD"):
		print(str(get_name(),' died'))
		self.get_node("Sprite").set_texture(DEAD_TEXTURE)
	update()


func on_state_exit(oldstate):
	pass

func _draw():
	if CHAR_STATE == "ACTIVE":
		draw_circle(Vector2(0,0),12,Color(0,0,0,0.3))

#=========================================================================================
# MANAGE STATUS
#=========================================================================================
func get_grid_pos():
	return GRID_POS

func set_grid_pos(new_pos):
	GRID_POS = new_pos
	self.set_pos(TERRAIN.map_to_world_centered(GRID_POS))

func get_HP():
	return HP

func get_MAX_HP():
	return MAX_HP

func modify_HP(HPmod):
	print(str("HP was: ",HP))
	HP += HPmod
	print(str("HP is: ",HP))
	if HP < 1 :
		HP = 0 # To avoid showing chars with negative HP
		change_state("DEAD")

func get_AP():
	return AP

func get_MAX_AP():
	return MAX_AP

func reduce_AP(fatigue):
	AP -= fatigue

func reset_status():
	AP = MAX_AP

func get_MP():
	return MP

func get_MAX_MP():
	return MAX_MP

#=========================================================================================
# MANAGE ACTIONS
#=========================================================================================
func get_avail_actions():
	return AVAIL_ACTIONS


func get_walkable_area():
	# initialize the array which is going to contain the walkable cells
	var walkable = {}
	walkable.cell = []
	walkable.AP_cost = []
	
	var walkmap = {}
	# move to the current position (not moving) imply no stamina consumption...
	walkmap[get_grid_pos()] = 0
	# ... and add current position to the walkable area
	walkable.cell.append(get_grid_pos())
	walkable.AP_cost.append(0)

	var curind = 0
	var newcoord = Vector2()
	var newval = null

	# Neighbouring cells [North, West, South, East]
	var neighbours = Vector2Array([Vector2(-1,0),Vector2(0,-1),Vector2(1,0),Vector2(0,1)])

	while (curind < walkable.cell.size()): # for each unprocessed cell
		if (walkmap[walkable.cell[curind]] < self.AP): # if not all stamina is consumed to move to that cell
			for neighbour in neighbours: # for each neighbouring cell
				newcoord = walkable.cell[curind] + neighbour # considered as newcoordinate
				newval = walkmap[walkable.cell[curind]] + TERRAIN.fatigue(newcoord) # and add the stamina consumption of the new cell to the current one
				if (not walkmap.has(newcoord) or walkmap[newcoord] > newval): # if the current path imply stamina consumption lower than that previously computed
					walkmap[newcoord] = newval   # update the stamina consumption map
					if (newval <= self.AP):  # if the stamina consumption of the current cell is less than char's stamina
						var tobeadded = true # mark the current cell as to be added
						for i in range(curind+1, walkable.cell.size()): # if the current cell...
							if (walkable.cell[i] == newcoord): # ... is in the list already
								tobeadded = false # ... mark it as not to be added
						if tobeadded: # if the current cell has to be added
							walkable.cell.append(newcoord) # add it
							walkable.AP_cost.append(newval)
		curind += 1

	curind = 0
	while (curind < walkable.cell.size()):
		var parsingindex = curind + 1
		while (parsingindex < walkable.cell.size()):
			if (walkable.cell[parsingindex] == walkable.cell[curind]):
				walkable.cell.erase(parsingindex)
				walkable.AP_cost.erase(parsingindex)
			else:
				parsingindex += 1
		curind += 1
	walkable.cell.pop_front()
	walkable.AP_cost.pop_front()
	return walkable


