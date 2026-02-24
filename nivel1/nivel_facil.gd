extends TileMapLayer


var niveles = ["res://nivel1//nivel_facil.tscn", "res://nivel2//nivel_medio.tscn"]
var nivel_actual = 0

func ir_a_siguiente():
	nivel_actual += 1
	if nivel_actual < niveles.size():
		get_tree().change_scene_to_file(niveles[nivel_actual])
