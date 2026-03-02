extends Node

var ultimo_checkpoint: Vector2 = Vector2.ZERO
var fotos_recogidas: Array = []

var musica_fondo = AudioStreamPlayer.new()
var reproductor_muerte = AudioStreamPlayer.new()

# ✅ Diccionario de niveles en orden
var niveles = [
	"res://niveles/tester/tester.tscn",
	"res://niveles/mapa_tutorial/mapa_tutorial.tscn",
	"res://niveles/nivel1/environment.tscn",
	"res://niveles/nivel2/nivel_medio.tscn",
	"res://niveles/nivel3/nivel_3.tscn",
	"res://niveles/mapa_final/envi_final.tscn",
	"res://niveles/mapa_victoria/victoria.tscn"
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
		

func _ready():
	# 1. Configurar Música de Fondo
	add_child(musica_fondo)
	# ⚠️ Cambia "musica_nivel.wav" por el nombre real de tu archivo
	musica_fondo.stream = load("res://global_assets/back_music.mp3") 
	musica_fondo.bus = "Master"
	
	# 2. Configurar Sonido de Muerte
	add_child(reproductor_muerte)
	reproductor_muerte.stream = load("res://global_assets/enemy_death.wav")
	reproductor_muerte.name = "snd_muerte" # Para que coincida con tus prints
	
	# 3. Arrancar la música nada más empezar el juego
	reproducir_musica_infinita()

func reproducir_muerte_monstruo():
	# Ahora usamos la variable que creamos arriba
	if reproductor_muerte.stream:
		reproductor_muerte.play()
		print("Sonido ejecutado correctamente")
	else:
		print("Error: El archivo de audio no se ha cargado")
		
# En Global.gd
func reproducir_musica_infinita():
	if musica_fondo.stream:
		musica_fondo.stream.loop = true 
		
		# ✅ Ajustamos el volumen a la mitad (-6.0 es un buen estándar)
		musica_fondo.volume_db = -18.0 
		
		if not musica_fondo.playing:
			musica_fondo.play()
			print("Música iniciada al 50% de volumen")
