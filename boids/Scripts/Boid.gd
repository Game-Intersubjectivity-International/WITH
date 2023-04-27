extends CharacterBody2D

const OVERALL_SPEED = 150

const SEPARATION_DISTANCE = 40
const ALIGNMENT_DISTANCE = 70

const SEPARATION_WEIGHT = 5
const ALIGNMENT_WEIGHT = 4
const COHESION_WEIGHT = 5

var FRAME_COUNT_Const = 1
var FRAME_COUNT = FRAME_COUNT_Const

var boid_velocity = Vector2.ZERO
var screen_size

var left
var top
var right
var bottom

func _ready():
	set_process(true)

func _process(delta: float) -> void:
	screen_size = get_viewport().get_visible_rect().size
	
	var boids = get_tree().get_nodes_in_group("boids")
	var players = get_tree().get_nodes_in_group("player")
	var player = players.front()
	var camera = player.get_node("Camera2D")
	var screen_center = camera.get_screen_center_position()
	
	left = screen_center.x - screen_size.x/2
	top = screen_center.y - screen_size.y/2
	right = left + screen_size.x
	bottom = top + screen_size.y
	
	
	var separation_vector = Vector2.ZERO
	var alignment_vector = Vector2.ZERO
	var cohesion_vector = Vector2.ZERO
	
	var separation_neighbors = 0
	var alignment_neighbors = 0
	var cohesion_neighbors = 0

	# boids.append(player)

	for boid in boids:
		if boid == self:
			continue
		var distance = self.global_position.distance_to(boid.global_position)
		if distance < SEPARATION_DISTANCE:
			separation_vector -= (boid.global_position - self.global_position) / distance
			separation_neighbors += 1
		if distance < ALIGNMENT_DISTANCE:
			alignment_vector += boid.boid_velocity.normalized()
			alignment_neighbors += 1

		cohesion_vector += boid.global_position
		cohesion_neighbors += 1
			
	if separation_neighbors > 0:
		separation_vector /= separation_neighbors
		if separation_vector.length_squared() > 0:
			separation_vector = separation_vector.normalized() * SEPARATION_WEIGHT * randf_range(0.5, 2)
	if alignment_neighbors > 0:
		alignment_vector /= alignment_neighbors
		if alignment_vector.length_squared() > 0:
			alignment_vector = alignment_vector.normalized() * ALIGNMENT_WEIGHT * randf_range(0.5, 2)
	if cohesion_neighbors > 0:
		cohesion_vector /= cohesion_neighbors
		if cohesion_vector.length_squared() > 0:
			cohesion_vector = (cohesion_vector - self.global_position).normalized() * COHESION_WEIGHT * randf_range(0.5, 2)


	boid_velocity += alignment_vector + cohesion_vector + separation_vector
	boid_velocity = boid_velocity.normalized() * min(boid_velocity.length(), 200)

	velocity = boid_velocity * delta * OVERALL_SPEED
	
	
	if FRAME_COUNT <= 0 :
		randomAnim()
		FRAME_COUNT = FRAME_COUNT_Const
	else : FRAME_COUNT -= 1
	move_and_slide()
	update_position()


func randomAnim():
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
		# left
		frame_x = 6
	
	frame_y = randi_range(0,8)
	$Sprite2D.frame = frame_x + frame_y * 9
		
		
		
func update_position():
	if global_position.x < left:
		global_position.x = right 
	if global_position.x > right:
		global_position.x = left
	if global_position.y < top:
		global_position.y = bottom
	if global_position.y > bottom:
		global_position.y = top

