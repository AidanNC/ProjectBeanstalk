extends Node3D

var rng = RandomNumberGenerator.new()

# rock bobs up and down
# public variable to control whether it starts boobbing up or down first
# this way we can set bobs next to each other to bob in opposite directions
@export var bob_up_first: bool = true
@export var bob_speed: float = 1.3  # How fast the bobbing happens
@export var bob_height: float = 0.5  # How high/low the rock bobs

var base_y: float  # Store the original Y position
var bob_time: float = 0.0  # Track bobbing time

func _ready():
	base_y = position.y  # Store the starting position

# make the rock bob up and down every so slightly and smoothly
func _physics_process(delta: float) -> void:
	bob_time += delta * bob_speed
	
	if bob_up_first:
		position.y = base_y + sin(bob_time) * bob_height
	if not bob_up_first:
		position.y = base_y - sin(bob_time) * bob_height
		
	rotation.y += 0.03 * delta * rng.randf_range(1.0, 3.0)

	
