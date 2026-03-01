extends Node

var ultimo_checkpoint: Vector2 = Vector2.ZERO
var fotos_recogidas: Array = []

# ✅ Diccionario de niveles en orden
var niveles = [
	"res://niveles/mapa_tutorial/mapa_tutorial.tscn",
	"res://niveles/nivel1/environment.tscn",
	"res://niveles/nivel2/nivel_medio.tscn"
]

func ir_al_siguiente_nivel():
	# 1. Buscamos en qué nivel estamos actualmente
	var escena_actual = get_tree().current_scene.scene_file_path
	var indice_actual = niveles.find(escena_actual)
	
	# 2. Si lo encuentra y hay un siguiente nivel...
	if indice_actual != -1 and indice_actual + 1 < niveles.size():
		# ✅ Limpiamos datos para el nuevo nivel
		ultimo_checkpoint = Vector2.ZERO
		fotos_recogidas.clear()
		
		# 3. Cambiamos a la siguiente ruta en el array
		get_tree().change_scene_to_file(niveles[indice_actual + 1])
	else:
		print("¡Fin del juego o nivel no registrado en el Array!")
