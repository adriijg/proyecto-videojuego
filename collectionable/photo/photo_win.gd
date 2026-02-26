extends Area2D

@export var puntos: int = 1  # Puntos que da al recogerlo

func _ready():
	# Nos aseguramos de que el coleccionable pueda detectar áreas o cuerpos
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _on_area_entered(area):
	# Si toca el AreaAtaque o cualquier otra área del samurai
	comprobar_contador(area.get_parent())

func _on_body_entered(body):
	# Si el cuerpo principal del samurai entra en el coleccionable
	comprobar_contador(body)

func comprobar_contador(objetivo):
	# Verificamos si es el samurai y si tiene el método sumar_puntos
	if (objetivo.name == "samurai" or objetivo.is_in_group("samurai")) and objetivo.has_method("sumar_puntos"):
		objetivo.sumar_puntos(puntos)
		print("Coleccionable recogido: +", puntos, " puntos")
		queue_free() # Elimina el coleccionable tras recogerlo
