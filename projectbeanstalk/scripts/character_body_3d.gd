extends CharacterBody3D
@export var camera: Camera3D
@export var speed: float = 2.0
@export var jumpVelocity: float = 4.0
@export var turnSpeed: float = 5.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var flying: bool = false
var _theta: float
var gliding: bool = false
var can_jump: bool = true

func _physics_process(delta: float) -> void:
	handleMovement()
	handleJump()
	applyGravity(delta)
	move_and_slide()

	rotate_player(delta)

	print(velocity)

func _process(_delta) -> void:
	if gliding:
		$BODY/Wings.visible = true
	else:
		$BODY/Wings.visible = false

	#check the movement ?
	if gliding:
		$BODY/AnimatedRig/AnimationPlayer.play("GLIDE CYCLE")
	elif velocity.x != 0 or velocity.z != 0:
		$"BODY/AnimatedRig/AnimationPlayer".play("RUN CYCLE")
	
	else:
		$"BODY/AnimatedRig/AnimationPlayer".play("IDLE CYCLE")
		
		

func rotate_player(delta):
	if velocity.x != 0 or velocity.z != 0:
		_theta = wrapf(atan2(velocity.x, velocity.z) - $BODY.rotation.y, -PI, PI)
		$BODY.rotation.y += clamp(turnSpeed * delta, 0, abs(_theta)) * sign(_theta)

		
func applyGravity(delta):
	
	velocity.y -= gravity * delta
	if gliding:
		velocity.y = max(velocity.y, -1)
	

func handleJump():
	if !can_jump && is_on_floor():
		can_jump = true
	if can_jump && Input.is_action_just_pressed("jump"):
		velocity.y = jumpVelocity
		can_jump = false
	if Input.is_action_pressed("jump"):
		gliding = true
	else:
		gliding = false
	
func handleMovement():
	# Get camera direction
	var camera_direction = camera.global_transform.basis.z
						 
	var move_direction = Vector3()
	# Input Handling
	# Pressing W moves forward on XZ plane in the direction the camera is facing
	if Input.is_action_pressed("move_forward"):
		# project camera direction onto XZ plane
		move_direction -= Vector3(camera_direction.x, 0, camera_direction.z)
		
	# Pressing S moves backward on XZ plane in the direction the camera is facing
	if Input.is_action_pressed("move_back"):
		move_direction += Vector3(camera_direction.x, 0, camera_direction.z)
		
	# Pressing A moves left on XZ plane in the direction the camera is facing
	if Input.is_action_pressed("move_left"):
		move_direction += Vector3(-camera_direction.z, 0, camera_direction.x)
		
	# Pressing D moves right on XZ plane in the direction the camera is facing
	if Input.is_action_pressed("move_right"):
		move_direction += Vector3(camera_direction.z, 0, -camera_direction.x)
		
	# Not pressing any movement keys
	if not Input.is_action_pressed("move_forward") and not Input.is_action_pressed("move_back") and not Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
		velocity.x = 0
		velocity.z = 0
		
	#not sure if this is doing anything
	move_direction = move_direction.normalized()
	velocity.z = move_direction.z * speed
	velocity.x = move_direction.x * speed
