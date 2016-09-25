extends Camera2D

var CAMERA_ENABLE = true

var CAMERA_SPEED = 80
var MAX_CAMERA_SPEED = 200
var deceleration = 5
var MIN_REACTIVE_LENGTH = Vector2(50,50)
var MAX_REACTIVE_LENGTH = Vector2(50,50)
#onready var MAX_WORLD_SIZE = get_parent().WORLD_SIZE
var LEFTBORDER = - 3000
var RIGHTBORDER = 4000
var TOPBORDER = -3000
var BOTTOMBORDER = 3000
var CAMERA_SIZE 

var MAXDIST = 10
var movingtopos_flag = false
var movingtopos = []
var targetpos

signal camera_moved

func _ready():
	self.set_pos(get_viewport_rect().size/2)
	CAMERA_SIZE = get_viewport_rect().size
	MAX_REACTIVE_LENGTH = CAMERA_SIZE - MIN_REACTIVE_LENGTH
	get_viewport().connect("size_changed",self,"update_camera_reaction_area")
	set_fixed_process(CAMERA_ENABLE)

func update_camera_reaction_area():
	CAMERA_SIZE = get_viewport_rect().size
	MAX_REACTIVE_LENGTH = CAMERA_SIZE-MIN_REACTIVE_LENGTH

func _fixed_process(delta):
	var MPOS = get_viewport().get_mouse_pos()
	var motion = Vector2(0,0)
	if movingtopos_flag:
		movingtopos = targetpos - get_pos()
		if movingtopos.length() < MAXDIST:
			movingtopos_flag = false
			emit_signal("camera_moved")
			
		var speed = min(MAX_CAMERA_SPEED,movingtopos.length()*deceleration)
		motion = movingtopos.normalized()*MAX_CAMERA_SPEED
	elif Input.is_action_pressed("move_camera"):
		var multiplier
		var constmultiplier = 2
		if (MPOS.x < MIN_REACTIVE_LENGTH.x):
			multiplier = (MIN_REACTIVE_LENGTH.x-MPOS.x)/MIN_REACTIVE_LENGTH.x
			multiplier *= constmultiplier
			multiplier = max(multiplier,1)
			motion -= Vector2(CAMERA_SPEED*multiplier,0)
		
		if (MPOS.y < MIN_REACTIVE_LENGTH.y):
			multiplier = (MIN_REACTIVE_LENGTH.y-MPOS.y)/MIN_REACTIVE_LENGTH.y
			multiplier *= constmultiplier
			multiplier = max(multiplier,1)
			motion -= Vector2(0,CAMERA_SPEED*multiplier)
			
		if (MPOS.x > MAX_REACTIVE_LENGTH.x):
			multiplier = (MPOS.x - MAX_REACTIVE_LENGTH.x)/MIN_REACTIVE_LENGTH.x
			multiplier *= constmultiplier
			multiplier = max(multiplier,1)
			motion += Vector2(CAMERA_SPEED*multiplier,0)
			
		if (MPOS.y > MAX_REACTIVE_LENGTH.y):
			multiplier = (MPOS.y - MAX_REACTIVE_LENGTH.y)/MIN_REACTIVE_LENGTH.y
			multiplier *= constmultiplier
			multiplier = max(multiplier,1)
			motion += Vector2(0,CAMERA_SPEED*multiplier)
	set_camera( get_pos() + motion*delta )


func set_camera(pos):
	if (pos.x-CAMERA_SIZE.x/2 < LEFTBORDER):
		pos.x = LEFTBORDER + CAMERA_SIZE.x/2
	elif(pos.x+CAMERA_SIZE.x/2 > RIGHTBORDER):
		pos.x = RIGHTBORDER - CAMERA_SIZE.x/2
	if (pos.y-CAMERA_SIZE.y/2 < TOPBORDER):
		pos.y = TOPBORDER + CAMERA_SIZE.y/2
	elif (pos.y+CAMERA_SIZE.y/2 > BOTTOMBORDER):
		pos.y = BOTTOMBORDER - CAMERA_SIZE.y/2
	self.set_pos(pos)


func move_camera_to(pos):
	targetpos = pos
	movingtopos_flag = true
	if not CAMERA_ENABLE:
		emit_signal("camera_moved")