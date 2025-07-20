extends Node3D

var rng = RandomNumberGenerator.new()
var time_elapsed: float = rng.randf_range(1.0, 5.0)


# make the rock bob up and down every so slightly and smoothly
func _physics_process(delta: float) -> void:
	time_elapsed += delta
	
	var factor = 0.02
	
	position.y += sin(time_elapsed) * factor
	rotation.y += 0.03 * delta * rng.randf_range(1.0, 3.0)

	
