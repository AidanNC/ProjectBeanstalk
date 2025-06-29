extends CharacterBody3D
@export var camera: Camera3D
@export var speed: float = 2.0
@export var jumpVelocity: float = 4.0
@export var turnSpeed: float = 5.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var flying: bool = false
var _theta: float
var gliding: bool = false
var can_glide: bool = false
var can_jump: bool = true

var left_wing_disabled = false
var right_wing_disabled = false

var lastSpeed = [0]

func _physics_process(delta: float) -> void:
	handleMovement()
	handleJump()
	applyGravity(delta)
	move_and_slide()
	handleWings()
	handleGlideTiming()

	rotate_player(delta)


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
	
	
	$BODY/Wings/Left_Wing.visible = !left_wing_disabled;
	$BODY/Wings/Right_Wing.visible = !right_wing_disabled;
	
		
		

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
		if can_glide:
			gliding = true
		else: 
			gliding = false
	else:
		gliding = false
		
		
const directionMap = {
	"NONE": 0,
	"FORWARD":  1,
	"BACKWARD": 2,
	"LEFT": 3, 
	"RIGHT": 4, 
}
		
func storeSpeed(direction: int):
	if lastSpeed[0] == direction:
		lastSpeed.append(direction)
	else:
		lastSpeed = [direction]
	
func handleMovement():
	# Get camera direction
	var camera_direction = camera.global_transform.basis.z
						 
	var move_direction = Vector3()
	# Input Handling
	# Pressing W moves forward on XZ plane in the direction the camera is facing
	if Input.is_action_pressed("move_forward"):
		# project camera direction onto XZ plane
		move_direction -= Vector3(camera_direction.x, 0, camera_direction.z)
		storeSpeed(directionMap["FORWARD"])
	# Pressing S moves backward on XZ plane in the direction the camera is facing
	if Input.is_action_pressed("move_back"):
		move_direction += Vector3(camera_direction.x, 0, camera_direction.z)
		storeSpeed(directionMap["BACKWARD"])
	# Pressing A moves left on XZ plane in the direction the camera is facing
	if Input.is_action_pressed("move_left") && !left_wing_disabled:
		move_direction += Vector3(-camera_direction.z, 0, camera_direction.x)
		storeSpeed(directionMap["LEFT"])
	# Pressing D moves right on XZ plane in the direction the camera is facing
	if Input.is_action_pressed("move_right") && !right_wing_disabled:
		move_direction += Vector3(camera_direction.z, 0, -camera_direction.x)
		storeSpeed(directionMap["RIGHT"])
	# Not pressing any movement keys
	if not Input.is_action_pressed("move_forward") and not Input.is_action_pressed("move_back") and not Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
		storeSpeed(directionMap["NONE"])
		
	##if both wings are gone then you can't move at all
	if left_wing_disabled && right_wing_disabled:
		storeSpeed(directionMap["NONE"])
		move_direction = Vector3.ZERO
	
	var acc = 0.4
	if lastSpeed[0] == directionMap["NONE"]:
		acc = max(0, speed-0.01*lastSpeed.size())
		
	
	move_direction = move_direction.normalized() * acc
	velocity += move_direction
	velocity.z = round(velocity.z * 0.98 * 100)/100
	velocity.x = round(velocity.x * 0.98 * 100)/100
	velocity.z = max(abs(velocity.z)-0.1, 0) * sign(velocity.z)
	velocity.x = max(abs(velocity.x)-0.1, 0) * sign(velocity.x)


func handleGlideTiming():
	if !is_on_floor() && $GlideTimer.is_stopped():
		$GlideTimer.start()
	if is_on_floor():
		can_glide = false
		$GlideTimer.stop()
		
		
	
func handleWings():
	if is_on_floor():
		left_wing_disabled = false
		right_wing_disabled = false
	

func _on_left_wing_body_entered(body: Node3D) -> void:
	if gliding:
		left_wing_disabled = true


func _on_right_wing_body_entered(body: Node3D) -> void:
	if gliding:
		right_wing_disabled = true


func _on_timer_timeout() -> void:
	can_glide = true
	print("can glide!")
	
