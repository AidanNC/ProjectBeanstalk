extends Node3D

@export var speed: float = 4.0
@export var radius: float = 5.0

var centerX = -1
var centerZ = -1
var circum = 2 * PI * radius
var theta = 0
func _physics_process(delta: float) -> void:
	#the bird will fly clockwise in a circle using the speed and radius provided
	#assume the bird is starting at 12 oclock
	var distance = speed * delta
	theta += (distance / circum) * 2 * PI
	theta = fmod(theta, (2 * PI)) 
	var x = radius * cos(theta) + centerX
	var z = radius * sin(theta) + centerZ
	global_position.x = x
	global_position.z = z
	#transform.basis = transform.basis.rotated(Vector3(0,1,0), theta)
	rotation = Vector3(0, -theta + (PI/2), 0)
	
	
	
func _ready() -> void:
	$BeanstalkBird/AnimationPlayer.play('ArmatureAction')
	var anim_length = $BeanstalkBird/AnimationPlayer.get_animation('ArmatureAction').length
	$BeanstalkBird/AnimationPlayer.seek(randf() * anim_length)
	centerX = global_position.x - radius
	centerZ = global_position.z
	
	
