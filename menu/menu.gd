extends Control

func _on_btn_start_pressed():
	# 1. Cambiamos a la escena del nivel tutorial
	get_tree().change_scene_to_file("res://niveles/mapa_tutorial/mapa_tutorial.tscn")
	
	# 2. Configuramos el volumen a -18 dB (que es un volumen suave)
	Global.musica_fondo.volume_db = -18.0
	
	# 3. Iniciamos la música
	Global.reproducir_musica_infinita()
	
func _on_btn_config_pressed():
	get_tree().change_scene_to_file("res://menu/config_menu/control.tscn")


func _on_btn_end_pressed():
	get_tree().quit()
 
# En el script del Menú
func _ready():
	# Opción A: Parar la música por completo
	Global.musica_fondo.stop()
	
	# Opción B: Si prefieres solo mutearla (ponerla en -80 dB)
	# Global.musica_fondo.volume_db = -80.0
