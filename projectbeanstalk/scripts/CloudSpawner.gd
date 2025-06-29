extends Node3D
@export var cloud_scene: PackedScene
@export var spawn_count: int = 10

@export var xmin: float = -100.0
@export var xmax: float = 100.0
@export var ymin: float = 21.0
@export var ymax: float = 100.0
@export var zmin: float = 0.0
@export var zmax: float = 100.0

@onready var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

	for i in range(spawn_count):
		var cloud = cloud_scene.instantiate()
		add_child(cloud)
		cloud.global_transform.origin = Vector3(rng.randf_range(xmin, xmax), rng.randf_range(ymin, ymax), rng.randf_range(zmin, zmax))
