extends Node

var currentTurn = 1
var Level1 = "res://Scenes/CombatScene/Levels/Level1.scn"
var currentScene = null

func _ready():
	currentScene = get_tree().get_root().get_child(get_tree().get_root().get_child_count()-1)

func matrix_init(nrow,ncol,fill):
	var M = {}
	for i in range(nrow):
		for j in range(ncol):
			M[Vector2(i,j)]=fill
	return M

func get_current_turn():
	return currentTurn

func setScene(scene):
	currentScene.queue_free()
	var s = ResourceLoader.load(scene)
	currentScene = s.instance()
	get_tree().change_scene_to(currentScene)
#	get_tree().get_root().add_child(currentScene)