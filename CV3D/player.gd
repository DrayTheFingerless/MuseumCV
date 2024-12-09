extends CharacterBody3D

@export var camera3D : Camera3D
# How fast the player moves in meters per second.
@export var speed = 30
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 75
# Vertical impulse applied to the character upon jumping in meters per second.
@export var jump_impulse = 30


@export var sensitivity = 100
var not_double_jumped = true

#inspect painting variables
@export var camera_following_player = true
var canInspect = false
var isAnimating = false
var currentJobId = -1
var currentPivot: Transform3D
var camTargetPosition: Transform3D
var previousCameraPos: Transform3D
var tDelta = 0.0

func _ready():
	set_as_top_level(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _physics_process(delta):
	# We create a local variable to store the input direction.
	#var direction = Vector3.ZERO
	#only move and calculate movement while not reading a painting
	if(isAnimating):
		#todo move camera and change prompt
		if(camTargetPosition != null):
			if(tDelta < 1.0):
				tDelta += delta*2
				print("tdelta:", tDelta)
				camera3D.global_transform = previousCameraPos.interpolate_with(camTargetPosition, tDelta)
			else:
				updatePrompt()
				tDelta = 0.0
				isAnimating = false
	elif(camera_following_player):
		var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var direction = (transform.basis *  -Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
		# We check for each move input and update the direction accordingly.
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
			
		# Vertical Velocity
		if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
			velocity.y = velocity.y - (fall_acceleration * delta)
			
		# Jumping.
		if Input.is_action_just_pressed("jump"):
			if is_on_floor():
				velocity.y = jump_impulse
				not_double_jumped = true
			elif not_double_jumped:
				velocity.y = jump_impulse
				not_double_jumped = false
			
		camera3D.global_transform = $CameraPivot.global_transform
		move_and_slide()
		
func _input(event):
	# Inspect
	if(Input.is_action_just_pressed("inspect") && canInspect):
		#send signal, with camera node, to gallery
		print("inspecting")
		if(camera_following_player):
			camTargetPosition = currentPivot
			previousCameraPos = camera3D.global_transform
			camera_following_player = false
			isAnimating = true
		
	# Inspect
	if(Input.is_action_just_pressed("ui_cancel") && !camera_following_player):
		#shift back to player mode
		previousCameraPos = camTargetPosition
		camTargetPosition = $CameraPivot.global_transform
		isAnimating = true
		camera_following_player = true
		
	if(event is InputEventMouseMotion && camera_following_player):
		rotate_y(-event.relative.x * 0.006)
		$CameraPivot.rotate_x(event.relative.y * 0.006)
		$CameraPivot.rotation.x = clamp($CameraPivot.rotation.x, deg_to_rad(-30), deg_to_rad(60))

func showPrompt(show: bool, body: Marker3D, jobId: int):
	get_tree().call_group("interface","showInspect", show && camera_following_player)
	print("body:", body.name)
	currentJobId = jobId
	currentPivot = body.global_transform
	camTargetPosition = body.global_transform
	canInspect = show && camera_following_player

func updatePrompt():
	get_tree().call_group("interface","changePrompt", camera_following_player, currentJobId)
	
