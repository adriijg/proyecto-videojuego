extends Camera2D

func _ready():
	enabled = true           # ACTIVA
	make_current()           # FUERZA ser la única cámara
	reset_smoothing()        # Reinicia smoothing
	print("🎥 CameraNivelMedio ACTIVADA - Límites: ", limit_right - limit_left)
