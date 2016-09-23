# Class for the generic character, which is extended to define actual
# classes of character, such as Lancer, Archer, ...
class Character:

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


	func _init():
		# associate sprites
		var sprite = Sprite.new()
		sprite.set_name("Sprite")
		self.add_child(sprite)

		# Set current state to inactive
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
		if (_CHAR_STATES.find(newstate)>-1):
			self.on_state_exit(self.CHAR_STATE)

			# print("Changing state of ",self.get_name()," from ",self.CHAR_STATE," to ",newstate)
			CHAR_STATE = newstate

			self.on_state_enter(newstate)
		else:
			print("Error in state handling, state ",newstate," does not exist.")
			self.get_tree().quit()


	func on_state_enter(newstate):
		# Method to be called when the FSM enters in a new state
		if (newstate == "ACTIVE"):
			update()
		#	self.get_node("Sprite").set_texture(TEXTURE)

		if (newstate == "IDLE"):
			self.reset_status()
			update()
			#self.get_node("Sprite").set_texture(TEXTURE)
		
		if (newstate == "DEAD"):
			print(str(get_name(),' died'))
			self.get_node("Sprite").set_texture(DEAD_TEXTURE)
#			get_parent().ALIVE_CHILDREN.erase(self)
#			print(get_parent().ALIVE_CHILDREN)



	func on_state_exit(oldstate):
		pass

	func _draw():
		#print("here")
		#print(CHAR_STATE)
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
	
	func modify_HP(HPmod):
		print(str("HP was: ",HP))
		HP += HPmod
		print(str("HP is: ",HP))
		if HP < 1 :
			change_state("DEAD")
	
	func get_AP():
		return AP

	func reduce_AP(fatigue):
		AP -= fatigue

	func reset_status():
		AP = MAX_AP

#=========================================================================================


	func get_avail_actions():
		return AVAIL_ACTIONS


	func get_walkable_area_old():
		# initialize the array which is going to contain the walkable cells
		var walkable = {}
		walkable.cell = []
		walkable.AP_cost = []
		# retrieve the terrain map
		var terrain_map = TERRAIN.get_terrain_map()
		# initialize the map of stamina consumption as unwalkable (AP+1)
		var walkmap = get_node("/root/globals").matrix_init(TERRAIN.nrow,TERRAIN.ncol,self.AP+1)
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
					if (newcoord.x >= 0 and newcoord.x <= TERRAIN.nrow-1 and newcoord.y >= 0 and newcoord.y <= TERRAIN.ncol-1): # check if it is in the map
						newval = walkmap[walkable.cell[curind]] + terrain_map[newcoord] # and add the stamina consumption of the new cell to the current one
						if (walkmap[newcoord] > newval): # if the current path imply stamina consumption lower than that previously computed
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
		return walkable


	func get_walkable_area():
		# initialize the array which is going to contain the walkable cells
		var walkable = {}
		walkable.cell = []
		walkable.AP_cost = []
		# retrieve the terrain map
		# var terrain_map = TERRAIN.get_terrain_map()
		# initialize the map of stamina consumption as unwalkable (AP+1)
		# var walkmap = get_node("/root/globals").matrix_init(TERRAIN.nrow,TERRAIN.ncol,self.AP+1)
		# move to the current position (not moving) imply no stamina consumption...
		var walkmap = {}
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
# Lancer character class
class Lancer:

	extends Character

	func _init():

		CLASS_TYPE = "Lancer"
		AVAIL_ACTIONS = ["Standard Attack","Sweep","Pierce","HammerDown"]
		DEAD_TEXTURE = ResourceLoader.load("res://Textures/Characters/deadplayer_20x20pxl.tex")
		MAX_HP = 4
		MAX_AP = 3
		MAX_MP = 0


	func _ready():

		if (self.TEAM == "P1"):
			TEXTURE = ResourceLoader.load("res://Textures/Characters/blueplayer_20x20pxl.tex")
		elif (self.TEAM == "P2"):
			TEXTURE = ResourceLoader.load("res://Textures/Characters/redplayer_20x20pxl.tex")

		# set the texture of the Lancer character
		get_node("Sprite").set_texture(TEXTURE)




# Archer character class
class Archer:

	extends Character

	func _init():

		CLASS_TYPE = "Archer"
		AVAIL_ACTIONS = ["Shot", "TripleArrow"]
		MAX_HP = 3
		MAX_AP = 4
		MAX_MP = 0


	func _ready():

		if (self.TEAM == "P1"):
			TEXTURE = ResourceLoader.load("res://Textures/Characters/blueplayer_20x20pxl.tex")
		elif (self.TEAM == "P2"):
			TEXTURE = ResourceLoader.load("res://Textures/Characters/redplayer_20x20pxl.tex")

		# set the texture of the Archer character
		get_node("Sprite").set_texture(TEXTURE)