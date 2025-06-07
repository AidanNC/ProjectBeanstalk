extends Node3D

var camrot_h: float = 0.0
var camrot_v: float = 0.0
var cam_v_min = -55
var cam_v_max = 75
var h_sensitivity = 0.1
var v_sensitivity = 0.1
var h_accel = 10.0
var v_accel = 10.0
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#$h/v/Camera.add_exception(get_parent())

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		camrot_h += -event.relative.x * h_sensitivity
		camrot_v += event.relative.y * v_sensitivity
		
func _physics_process(delta: float) -> void:

	camrot_v = clamp(camrot_v, cam_v_min, cam_v_max)
	
	$h.rotation_degrees.y = lerp($h.rotation_degrees.y, camrot_h, delta * h_accel)
	$h/v.rotation_degrees.x = lerp($h/v.rotation_degrees.x, camrot_v, delta * v_accel)
	
