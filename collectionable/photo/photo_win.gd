extends Area2D

@export var puntos: int = 1

func _ready():
	# ✅ Si el nombre de esta foto ya está en la lista global, la borramos al empezar
	if name in Global.fotos_recogidas:
		queue_free()
		return
		
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _on_area_entered(area):
	comprobar_contador(area.get_parent())

func _on_body_entered(body):
	comprobar_contador(body)

func comprobar_contador(objetivo):
	var hbox_contador = objetivo.find_child("hbox_contador")
	if hbox_contador and hbox_contador.has_method("sumar_puntos"):
		# ✅ Guardamos el nombre de esta foto en el Global antes de desaparecer
		if not name in Global.fotos_recogidas:
			Global.fotos_recogidas.append(name)
			
		hbox_contador.sumar_puntos(puntos)
		queue_free()
