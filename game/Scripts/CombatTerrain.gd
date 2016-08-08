
extends Sprite

var mapsize = {}
var ncol = 20
var nrow = 20

func _ready():
	mapsize["width"] = self.get_texture().get_size().width
	mapsize["height"] = self.get_texture().get_size().height
	set_process_input(true)

func grit_init():
	pass

func global2grid_coord(pos):
	return Vector2(int(pos[1]*nrow/mapsize.height),int(pos[0]*ncol/mapsize.width))

func grid2global_coord(grid_pos):
	return Vector2((grid_pos[1]+0.5)*mapsize.height/nrow,(grid_pos[0]+0.5)*mapsize.width/ncol)