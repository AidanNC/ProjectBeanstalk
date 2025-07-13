extends Node3D

var velocity := Vector3.ZERO

func _ready() -> void:
	var big_cloud = get_node("BigCloud")
	var small_cloud = get_node("SmallCloud")

	big_cloud.visible = false
	small_cloud.visible = false

#	big = 1, small = 0
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var choice = 0 if rng.randf() > 0.7 else 1

	if choice == 1:
		big_cloud.visible = true
	else:
		small_cloud.visible = true
	
	var speed = rng.randf_range(-4.0, 4.0)
	
	velocity = Vector3(speed, 0, 0)

func _process(delta: float) -> void:
	position.x += velocity.x * delta

	if position.x < -100:
		position.x = 100
	if position.x > 100:
		position.x = -100

func _physics_process(delta: float) -> void:
	translate(velocity * delta)
	

func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	queue_free()
