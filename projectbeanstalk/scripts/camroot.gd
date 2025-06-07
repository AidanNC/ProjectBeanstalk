extends Node3D

var camrotH: float = 0.0
var camrotV: float = 0.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#$h/v/Camera.add_exception(get_parent())

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		camrotH += -event.relative.x
		camrotV += event.relative.y
		
func _physics_process(_delta: float) -> void:
	
	$h/v.rotation_degrees.x = camrotV
	$h.rotation_degrees.y = camrotH
