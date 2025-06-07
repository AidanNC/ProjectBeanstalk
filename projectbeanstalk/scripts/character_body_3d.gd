extends CharacterBody3D
@export var camera: Camera3D
@export var speed: float = 10.0

func _physics_process(delta: float) -> void:
	handleMovement()
	move_and_slide()
	
func handleMovement():
	var input_dir = Vector3.ZERO
	
	if Input.is_action_pressed("move_forward"):
		input_dir.z -= 1
	if Input.is_action_pressed("move_back"):
		input_dir.z += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	
	# Normalize input direction to prevent faster diagonal movement
	input_dir = input_dir.normalized()
	
	if input_dir != Vector3.ZERO:
		# Get the camera's forward and right vectors, but ignore the Y component
		var camera_forward = camera.global_transform.basis.z
		var camera_right = camera.global_transform.basis.x
		camera_forward.y = 0
		camera_right.y = 0
		camera_forward = camera_forward.normalized()
		camera_right = camera_right.normalized()
		
		# Calculate movement direction relative to camera
		var move_direction = camera_forward * input_dir.z + camera_right * input_dir.x
		move_direction = move_direction.normalized()
		
		# Set velocity
		velocity.x = move_direction.x * speed
		velocity.z = move_direction.z * speed
		
		# Make the character face the movement direction
		look_at(position + move_direction, Vector3.UP)
	else:
		velocity.x = 0
		velocity.z = 0

func _input(event):
	if event is InputEventMouseMotion:
		print(event.velocity)
		

	

		
		
