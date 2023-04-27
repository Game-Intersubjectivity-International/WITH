extends CharacterBody2D

var MAX_SPPED = 500
var ACCELERATION_COEFIICIENT = 300
var FRICTION_COEFIICIENT = 50

var FRAME_COUNT_Const = 1
var FRAME_COUNT = FRAME_COUNT_Const

var input_vector = Vector2.ZERO

var boids = []

var boid_velocity

var near_num = 0

@onready var audio = self.get_node("AudioStreamPlayer")
@onready var audio2 = self.get_node("AudioStreamPlayer2")
@onready var timer = self.get_node("Timer")

func _process(delta):
	play_voice()
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	if Input.is_action_just_pressed("ui_focus_next"):
		get_tree().reload_current_scene()

func _physics_process(delta):
	move(delta)
	change_anim()
	if FRAME_COUNT <= 0 :
		rand_anim()
		FRAME_COUNT = FRAME_COUNT_Const
	else : FRAME_COUNT -= 1
	boid_velocity = velocity
	

func _ready():
	boids = get_tree().get_nodes_in_group("boids")

func move(delta):
	# 获取当前按下的键盘按键
	input_vector = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1
	if Input.is_action_pressed("ui_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_down"):
		input_vector.y += 1
	if Input.is_action_pressed("ui_up"):
		input_vector.y -= 1

	# 根据输入方向计算移动速度
	input_vector = input_vector.normalized()
	
	var Acceleration = input_vector * ACCELERATION_COEFIICIENT
	var Friction = velocity.normalized() * FRICTION_COEFIICIENT
		
	velocity = velocity + Acceleration * delta
	
	if (velocity.abs() < (Friction * delta).abs()):
		velocity = Vector2.ZERO
			
	if (input_vector.length() == 0):
		velocity = velocity - Friction * delta
	
	move_and_slide()
	
	if (velocity.length() > MAX_SPPED):
		velocity = velocity.normalized() * MAX_SPPED

func rand_anim():
	var frame_x = 0
	var frame_y = 0
	
	if velocity.length() < 400 : 
		frame_x = 4
	elif abs(velocity.angle()) <= PI/8 :
		# 右
		frame_x = 8
	elif abs(velocity.angle()) <= PI * 3/8:
		# 右上或右下
		if velocity.angle() < 0 : 
			frame_x = 2
		else : 
			frame_x = 3
	elif abs(velocity.angle()) <= PI * 5/8:
		# 上或者下
		if velocity.angle() < 0 :
			frame_x = 1
		else:
			frame_x = 7
	elif abs(velocity.angle()) <= PI * 7/8:
		# 左上或者左下
		if velocity.angle() < 0 : 
			frame_x = 0		
		else : 
			frame_x = 5
	else:
		frame_x = 6
	
	frame_y = randi_range(0,8)
	$Sprite2D.frame = frame_x + frame_y * 9

func play_voice():
	if (near_num <= 0):
		audio.volume_db = -20
		audio2.volume_db = -10
	elif (near_num >= 70):
		audio.volume_db = 0
		audio2.volume_db = -15
	else :
		audio.volume_db = (2 * near_num)/7 - 20
		audio2.volume_db = -10 - (near_num * 5)/70
		
	audio.volume_db += 15
	audio2.volume_db += 15

func change_anim():
	if (near_num <= 0):
		FRAME_COUNT_Const = 1
		for boid in boids:
			boid.FRAME_COUNT_Const = 1			
	elif (near_num > 0 && near_num <= 30):
		FRAME_COUNT_Const = 2
		for boid in boids:
			boid.FRAME_COUNT_Const = 2
	elif (near_num > 30 && near_num <= 60):
		FRAME_COUNT_Const = 3
		for boid in boids:
			boid.FRAME_COUNT_Const = 3
	elif (near_num > 60):
		FRAME_COUNT_Const = 4
		for boid in boids:
			boid.FRAME_COUNT_Const = 4

func _on_area_2d_area_entered(area):
	near_num += 1
	if(near_num > 70):
		near_num = 70
	
func _on_area_2d_area_exited(area):
	near_num -= 1
	if(near_num < 0):
		near_num = 0

func _on_audio_stream_player_finished():
	audio.play()

func _on_audio_stream_player_2_finished():
	audio2.play()

func _on_timer_timeout():
	get_tree().reload_current_scene()
