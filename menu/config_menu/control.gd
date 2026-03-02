extends Control

# ✅ Arrastra aquí tus imágenes desde el FileSystem
@export var img_teclado: Texture2D = preload("res://menu/config_menu/img/menu_config_pc.jpg")
@export var img_mando: Texture2D = preload("res://menu/config_menu/img/menu_config_xbox.jpg")

@onready var btn_alternar = $btn_alternar_mando
@onready var visualizador = $img_controles

var modo_mando: bool = false

func _ready():
	# Empezamos con teclado por defecto
	visualizador.texture = img_teclado
	btn_alternar.text = "Ver Controles: MANDO"

func _on_btn_alternar_mando_pressed() -> void:
	modo_mando = !modo_mando # Cambia entre verdadero/falso
	
	if modo_mando:
		visualizador.texture = img_mando
		btn_alternar.text = "Ver Controles: TECLADO"
	else:
		visualizador.texture = img_teclado
		btn_alternar.text = "Ver Controles: MANDO"

func _on_btn_back_pressed() -> void:
	get_tree().change_scene_to_file("res://menu/menu.tscn")
