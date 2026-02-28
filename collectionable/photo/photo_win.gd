extends Area2D

@export var puntos: int = 1

func _ready():
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _on_area_entered(area):
	comprobar_contador(area.get_parent())

func _on_body_entered(body):
	comprobar_contador(body)

func comprobar_contador(objetivo):
	# Busca el HBoxContainer en la jerarquía del samurai
	var hbox_contador = objetivo.find_child("hbox_contador")
	if hbox_contador and hbox_contador.has_method("sumar_puntos"):
		hbox_contador.sumar_puntos(puntos)
		queue_free()
