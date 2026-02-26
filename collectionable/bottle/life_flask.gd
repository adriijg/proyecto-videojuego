extends Area2D

@export var curacion: int = 2

func _ready():
	# Nos aseguramos de que el frasco pueda detectar áreas o cuerpos
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _on_area_entered(area):
	# Si toca el AreaAtaque o cualquier otra área del samurai
	comprobar_curacion(area.get_parent())

func _on_body_entered(body):
	# Si el cuerpo principal del samurai entra en el frasco
	comprobar_curacion(body)

func comprobar_curacion(objetivo):
	# Verificamos si es el samurai y si tiene el método curar
	if (objetivo.name == "samurai" or objetivo.is_in_group("samurai")) and objetivo.has_method("curar"):
		objetivo.curar(curacion)
		print("Curando al samurai...")
		queue_free() # Elimina el frasco tras la curación
