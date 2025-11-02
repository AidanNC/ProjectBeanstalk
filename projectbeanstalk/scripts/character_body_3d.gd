extends CharacterBody3D
@export var camera: Camera3D
@export var speed: float = 2.0
@export var jumpVelocity: float = 10.0
@export var turnSpeed: float = 5.0

@onready var anim = $"BODY/AnimatedRig/AnimationPlayer"
@onready var run_players = {
	"GRASS": $Sound/RunGrass,
	"LEAF":  $Sound/RunLeaf,
	"ROCK":  $Sound/RunRock
}
@onready var legacy_run = $Sound/Run  # old one you’re phasing out

var current_surface := ""
var current_player = null

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var flying: bool = false
var _theta: float
var gliding: bool = false
var can_glide: bool = false
var can_jump: bool = true
var is_running := false

var left_wing_disabled = false
var right_wing_disabled = false


var lastSpeed = [0]

#for rng 
var rng = RandomNumberGenerator.new()

func _physics_process(delta: float) -> void:
	handleMovement()
	handleJump()
	applyGravity(delta)
	move_and_slide()
	handle_sounds_and_animations()
	handleWings()
	handleGlideTiming()

	rotate_player(delta)


func _process(_delta: float) -> void:
	if gliding:
		$BODY/Wings.visible = true
	else:
		$BODY/Wings.visible = false
		
	$"BODY/Wings/WingAnimation/wing!".visible = !left_wing_disabled
	$"BODY/Wings/WingAnimation/wing!_001".visible = !right_wing_disabled
	
	if gliding:
		anim.play("GLIDE CYCLE")
		$BODY/Wings/WingAnimation/AnimationPlayer.play("WING CYCLE R")
		$BODY/Wings/WingAnimation/AnimationPlayer.play("WING CYCLE L")
	elif velocity.x != 0 or velocity.z != 0:
		anim.play("RUN CYCLE")
		if lastSpeed[0] == directionMap["NONE"]:
			anim.play("SLIDE STOP")
	else:
		if $BODY/OnEdgeHitBox.get_overlapping_bodies().size() == 0:
			anim.play("EDGE WOBBLE CYCLE")
		else:
			anim.play("IDLE CYCLE")
		
		
func handle_sounds_and_animations():
	# Gliding logic
	if gliding:
		stop_all_run_sounds()
		is_running = false
		return

	# On floor logic
	elif velocity.x != 0 or velocity.z != 0:
		var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
		
		# Player is running
		if horizontal_velocity.length() > 0.1:
			if !is_running:
				is_running = true

			var collision = get_last_slide_collision()
			if collision and collision.get_collider():
				current_surface = collision.get_collider().get_owner().name
				# print(current_surface) # I'll comment this out as it's likely for debugging
				set_running_sound(current_surface)
			else:
				stop_all_run_sounds()

		# Player is stopping or stopped
		else:
			if is_running:
				is_running = false
				stop_all_run_sounds()
	# Player is in the air
	else:
		if is_running:
			is_running = false
			stop_all_run_sounds()


func rotate_player(delta):
	if velocity.x != 0 or velocity.z != 0:
		_theta = wrapf(atan2(velocity.x, velocity.z) - $BODY.rotation.y, -PI, PI)
		$BODY.rotation.y += clamp(turnSpeed * delta, 0, abs(_theta)) * sign(_theta)

		
func applyGravity(delta):
	
	velocity.y -= gravity * delta
	if gliding:
		velocity.y = max(velocity.y, -1)
	
func stop_all_run_sounds():
	for p in run_players.values(): if p.playing: p.stop()
	if legacy_run and legacy_run.playing: legacy_run.stop()

func set_running_sound(surface: String):
	var key = surface.to_upper()
	var next_player = null
	if key.contains("BEANSTALK") or key.contains("FLOOR"): next_player = run_players["GRASS"]
	elif key.contains("LEAF"):  next_player = run_players["LEAF"]
	elif key.contains("ROCK") or key.contains("ISLAND"):  next_player = run_players["ROCK"]

	if next_player != current_player:
		if current_player: current_player.stop()
		current_player = next_player
		
	if current_player and !current_player.playing:
		current_player.play()

func handleJump():
	if !can_jump && is_on_floor():
		can_jump = true
	if can_jump && Input.is_action_just_pressed("jump"):
		velocity.y = jumpVelocity
		can_jump = false
		#randomly play one of the jump sounds
		if rng.randi_range(0,2) == 1: 
			$Sound/Jump1.play(0.03)
		else:
			$Sound/Jump2.play(0.07)
	if Input.is_action_pressed("jump"):
		if can_glide and !(left_wing_disabled and right_wing_disabled):
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
	"FREE_FALL": 5
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
		
	##if both wings are gone then you can only move very slowly
	if left_wing_disabled && right_wing_disabled:
		storeSpeed(directionMap["FREE_FALL"])
	
	var acc = 0.4
	if lastSpeed[0] == directionMap["NONE"]:
		acc = max(0, speed-0.01*lastSpeed.size())
	elif lastSpeed[0] == directionMap["FREE_FALL"]:
		acc = 0.2 #you move very slowly if both wings are broken
		
	
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
	

func _on_left_wing_body_entered(_body: Node3D) -> void:
	if gliding:
		left_wing_disabled = true


func _on_right_wing_body_entered(_body: Node3D) -> void:
	if gliding:
		right_wing_disabled = true


func _on_timer_timeout() -> void:
	can_glide = true
	
