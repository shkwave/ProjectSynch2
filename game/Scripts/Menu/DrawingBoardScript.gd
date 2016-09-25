
extends Node2D

onready var WORLD = get_tree().get_root().get_node("World")
onready var TERRAIN = WORLD.get_node("Terrain")
onready var HUD = get_parent()

func _draw():
	if (WORLD.get_state() == "Action_Specifics"):
		if (HUD.ActSelReq.flag > 0):
			var rectsize = Vector2(20,20)
			for tile in HUD.ActSelReq.requesting_action.global_selectable_area:
				draw_rect(Rect2(TERRAIN.map_to_world_centered(tile)-rectsize/2,rectsize),Color(1,0.816,0.1216,0.7))
			if HUD.ActSelReq.draw_temp :
				if (HUD.ActSelReq.requesting_action.AoE_rotate):
					HUD.ActSelReq.requesting_action.AoE_update(HUD.ActSelReq.temp_reply)
				for tile in HUD.ActSelReq.requesting_action.AoE:
					draw_rect(Rect2(TERRAIN.map_to_world_centered(tile+HUD.ActSelReq.temp_reply)-rectsize/2,rectsize),Color(1,0.341,0.173,0.4))
		if (HUD.ActSelReq.flag == 2):
			var rectsize = Vector2(12,12)
			if (HUD.ActSelReq.requesting_action.AoE_rotate):
				HUD.ActSelReq.requesting_action.AoE_update(HUD.ActSelReq.reply)
			for tile in HUD.ActSelReq.requesting_action.AoE:
				draw_rect(Rect2(TERRAIN.map_to_world_centered(tile+HUD.ActSelReq.reply)-rectsize/2,rectsize),Color(0.91,0.11,0.478,1))

