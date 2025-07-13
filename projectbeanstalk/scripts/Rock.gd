extends Node3D


@export var isSmallRock = true
var rng = RandomNumberGenerator.new()
var time_elapsed: float = randf_range(1.0, 3.0)

func _ready() -> void:
	var smallrock = get_node("rock1")
	var bigrock = get_node("rock2")

	if isSmallRock:
		smallrock.visible = true
		bigrock.visible = false
	else:
		smallrock.visible = false
		bigrock.visible = true


# make the rock bob up and down every so slightly and smoothly
func _physics_process(delta: float) -> void:
	time_elapsed += delta
	
	var factor = 0.02 if isSmallRock else 0.05
	
	position.y += sin(time_elapsed) * factor

	
