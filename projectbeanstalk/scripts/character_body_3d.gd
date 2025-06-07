extends CharacterBody3D
@export var camera: Camera3D
@export var speed: float = 2.0

func _physics_process(delta: float) -> void:
	handleMovement()
	move_and_slide()
	
func handleMovement():
	# Get camera direction
	var camera_direction = camera.global_transform.basis.z
	
	# Input Handling
	# Pressing W moves forward on XZ plane in the direction the camera is facing
	if Input.is_action_pressed("move_forward"):
		# project camera direction onto XZ plane
		var move_direction = Vector3(camera_direction.x, 0, camera_direction.z)
		velocity = -move_direction * speed
	# Pressing S moves backward on XZ plane in the direction the camera is facing
	if Input.is_action_pressed("move_back"):
		var move_direction = Vector3(camera_direction.x, 0, camera_direction.z)
		velocity = move_direction * speed
	# Pressing A moves left on XZ plane in the direction the camera is facing
	if Input.is_action_pressed("move_left"):
		var move_direction = Vector3(-camera_direction.z, 0, camera_direction.x)
		velocity = move_direction * speed
	# Pressing D moves right on XZ plane in the direction the camera is facing
	if Input.is_action_pressed("move_right"):
		var move_direction = Vector3(camera_direction.z, 0, -camera_direction.x)
		velocity = move_direction * speed
	
	# Not pressing any movement keys
	if not Input.is_action_pressed("move_forward") and not Input.is_action_pressed("move_back") and not Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
		velocity = Vector3.ZERO
	

func _input(event):
	if event is InputEventMouseMotion:
		print(event.velocity)
		

	

		
		
