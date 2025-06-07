extends CharacterBody3D
@export var camera: Camera3D
@export var speed: float = 2.0
@export var jumpVelocity: float = 4.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta: float) -> void:
	handleMovement()
	handleJump()
	applyGravity()
	move_and_slide()
	

func applyGravity():
	velocity.y -= gravity * get_physics_process_delta_time()

func handleJump():
	if Input.is_action_just_pressed("jump"):
		velocity.y = jumpVelocity
	
func handleMovement():
	# Get camera direction
	var camera_direction = camera.global_transform.basis.z
						 
	# Input Handling
	# Pressing W moves forward on XZ plane in the direction the camera is facing
	if Input.is_action_pressed("move_forward"):
		# project camera direction onto XZ plane
		var move_direction = Vector3(camera_direction.x, 0, camera_direction.z)
		velocity.z = -move_direction.z * speed
		velocity.x = -move_direction.x * speed
	# Pressing S moves backward on XZ plane in the direction the camera is facing
	if Input.is_action_pressed("move_back"):
		var move_direction = Vector3(camera_direction.x, 0, camera_direction.z)
		velocity.z = move_direction.z * speed
		velocity.x = move_direction.x * speed
	# Pressing A moves left on XZ plane in the direction the camera is facing
	if Input.is_action_pressed("move_left"):
		var move_direction = Vector3(-camera_direction.z, 0, camera_direction.x)
		velocity.z = move_direction.z * speed
		velocity.x = move_direction.x * speed
	# Pressing D moves right on XZ plane in the direction the camera is facing
	if Input.is_action_pressed("move_right"):
		var move_direction = Vector3(camera_direction.z, 0, -camera_direction.x)
		velocity.z = move_direction.z * speed
		velocity.x = move_direction.x * speed
	# Not pressing any movement keys
	if not Input.is_action_pressed("move_forward") and not Input.is_action_pressed("move_back") and not Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
		velocity.x = 0
		velocity.z = 0
	
		

	

		
		
