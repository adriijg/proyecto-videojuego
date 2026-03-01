extends Area2D

var activado: bool = false
@onready var ani_sprite = $ani_bomb # O el nodo que tenga tu katana

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if (body.is_in_group("samurai") or body.name == "samurai") and not activado:
		activado = true
		activar_checkpoint()

func activar_checkpoint():
	# 1. Guardamos la posición en un Singleton (Autoload) llamado 'Global'
	# Debes crear un script llamado Global.gd en Ajustes del Proyecto -> Autoload
	Global.ultimo_checkpoint = global_position
	
	# 2. Feedback visual (puedes cambiar el color de la cinta roja)
	modulate = Color(1.5, 1.5, 1.5) # Brillo de activado
	print("Checkpoint alcanzado: ", global_position)
	
	# 3. Opcional: Reproducir sonido de viento o campana
	if has_node("audio_checkpoint"):
		$audio_checkpoint.play()
