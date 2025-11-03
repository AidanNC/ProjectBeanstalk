extends Camera3D

@export var blur_far_max := 100
@export var blur_far_min := 3

@export var blur_near_max := 2
@export var blur_near_min := 0

@export var blur_range := -2

var lerp_speed := 10.0

func _physics_process(delta: float) -> void:
	$BlurRange.target_position.z = blur_range
	
	if $BlurRange.is_colliding():
		var origin = $BlurRange.global_transform.origin
		var collision_point = $BlurRange.get_collision_point()
		var distance = origin.distance_to(collision_point)
		self.attributes.dof_blur_far_distance = blur_far_min*distance
		self.attributes.dof_blur_near_distance = blur_near_min
	else:
		self.attributes.dof_blur_far_distance = blur_far_max
		self.attributes.dof_blur_near_distance = blur_near_max
