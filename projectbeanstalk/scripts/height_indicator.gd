extends CanvasLayer

var count = 1

func _process(delta: float) -> void:
	var height = $Player/Player_Body.global_position.y
	count +=1 
	$"Height_Indicator".text = str(round(height))
