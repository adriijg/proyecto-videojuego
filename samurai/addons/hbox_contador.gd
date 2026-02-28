extends HBoxContainer

@export var total_objetivos: int = 3  # ← CAMBIA ESTE NÚMERO SEGÚN TUS FOTOS
@export var valor_inicial: int = 0

@onready var lbl_contador: Label = $lbl_contador
@onready var sprt_contador: Sprite2D = $sprt_contador

var contador: int = 0

func _ready():
	contador = valor_inicial
	actualizar_ui()

# Función pública para sumar desde coleccionables
func sumar_puntos(cantidad: int) -> void:
	contador += cantidad
	actualizar_ui()
	print("Fotos: ", contador, "/", total_objetivos)

func actualizar_ui() -> void:
	if lbl_contador:
		# FORMATO "0/3" ← SOLO cambia el 0
		lbl_contador.text = str(contador) + "/" + str(total_objetivos)
	
	# Feedback visual opcional
	if sprt_contador:
		var t = create_tween()
		t.tween_property(sprt_contador, "modulate", Color.YELLOW, 0.1)
		t.tween_property(sprt_contador, "modulate", Color.WHITE, 0.1)
