
extends TileMap

var base_terrain_map = {}
var avail_cell = Vector2Array()
var blocked_value = 100
var type0 = 0

func _ready():
	for cell in get_used_cells():
		if get_cellv(cell) == type0:
			avail_cell.push_back(cell)
	#print(avail_cell)
			

func is_available(cell):
	#print(cell)
	if find_elem_in(cell,avail_cell)<0:
		return false
	else:
		return true

func is_free(cell):
	if find_elem_in(cell,avail_cell)<0 :
		return false
	for char in get_tree().get_nodes_in_group("Characters"):
		if char.get_grid_pos() == cell:
			return false
	return true

func fatigue(cell):
	if is_available(cell):
		for char in get_tree().get_nodes_in_group("Characters"):
			if cell == char.get_grid_pos():
				return blocked_value
		if get_cellv(cell) == type0:
			return 1
	else:
		return blocked_value

func map_to_world_centered(grid_pos):
	var pos = map_to_world(grid_pos)
	return pos + get_cell_size()/2

func find_elem_in(value,arrayvector2):
	#print(str("searching value",value))
	#print(str("in ", arrayvector2))
	#print(str("sizeof arrayvector2",arrayvector2.size()))
	for indx in range(arrayvector2.size()):
		#print(str("comparing",arrayvector2[indx],"with",value))
		if (arrayvector2[indx] - value).length()<0.01:
			return indx
	return -1