extends Area2D

@onready var timer = $Timer
var cuerpo_en_pinchos = null
var danio = 10

func _ready():
	# Conectamos las señales necesarias
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	timer.timeout.connect(_aplicar_danio_continuo)

func _on_body_entered(body):
	if body.is_in_group("samurai"):
		cuerpo_en_pinchos = body
		_aplicar_danio_continuo() # Primer golpe al entrar

func _on_body_exited(body):
	if body == cuerpo_en_pinchos:
		cuerpo_en_pinchos = null
		timer.stop() # Deja de contar si sale de los pinchos

func _aplicar_danio_continuo():
	if cuerpo_en_pinchos and cuerpo_en_pinchos.has_method("recibir_danio"):
		cuerpo_en_pinchos.recibir_danio(danio)
		timer.start() # Reinicia el cooldown de 2 segundos
