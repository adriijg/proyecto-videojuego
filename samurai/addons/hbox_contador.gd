extends HBoxContainer

@export var total_objetivos: int = 3
@export var valor_inicial: int = 0

@onready var lbl_contador: Label = $lbl_contador
@onready var sprt_contador: Sprite2D = $sprt_contador

var contador: int = 0

func _ready():
	# ✅ Al empezar, el contador lee cuántas fotos hay guardadas en Global
	contador = Global.fotos_recogidas.size()
	actualizar_ui()

func sumar_puntos(cantidad: int) -> void:
	# ✅ Ya no sumamos aquí directamente, sino que refrescamos con el tamaño de la lista
	contador = Global.fotos_recogidas.size()
	actualizar_ui()
	print("Fotos: ", contador, "/", total_objetivos)

func actualizar_ui() -> void:
	if lbl_contador:
		lbl_contador.text = str(contador) + "/" + str(total_objetivos)
	
	if sprt_contador:
		var t = create_tween()
		t.tween_property(sprt_contador, "modulate", Color.YELLOW, 0.1)
		t.tween_property(sprt_contador, "modulate", Color.WHITE, 0.1)
