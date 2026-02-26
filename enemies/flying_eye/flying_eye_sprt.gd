extends Area2D

@export var proyectil_scene: PackedScene
@export var cadencia: float = 2.0
@export var velocidad_seguimiento: float = 1.5 # Ajustado para un movimiento suave
@export var vida: int = 1 

var posicion_y_fija: float
var samurai: Node2D = null # Solo tendrá valor si está en el rango

@onready var ani_flying_eye = $ani_flying_eye
@onready var mark_flying_eye = $mark_flying_eye
@onready var timer_flying_eye = $timer_flying_eye
@onready var col_flying_eye = $col_flying_eye
@onready var area_muerte = $col_muerte # Según tu imagen

func _ready():
	posicion_y_fija = global_position.y
	
	timer_flying_eye.wait_time = cadencia
	timer_flying_eye.timeout.connect(_lanzar_proyectil)
	timer_flying_eye.start()

	ani_flying_eye.play("attack")

	# Conexión para morir (detecta el área de ataque del jugador)
	if area_muerte:
		area_muerte.area_entered.connect(_on_area_muerte_entered)
	
	# NUEVO: Conexiones para el área de detección
	if has_node("area_deteccion"):
		$area_deteccion.body_entered.connect(_on_detection_body_entered)
		$area_deteccion.body_exited.connect(_on_detection_body_exited)

func _physics_process(delta):
	# SOLO SE MUEVE SI EL SAMURAI ESTÁ EN RANGO
	if samurai and is_instance_valid(samurai):
		var target_x = samurai.global_position.x
		# Interpolación lineal (lerp) para que el movimiento sea fluido y no instantáneo
		global_position.x = lerp(global_position.x, target_x, velocidad_seguimiento * delta)
		global_position.y = posicion_y_fija
	else:
		# Si no hay samurai, se queda quieto o podrías poner una patrulla
		ani_flying_eye.play("attack") # O una animación de idle

# --- LÓGICA DE DETECCIÓN ---
func _on_detection_body_entered(body):
	if body.is_in_group("samurai") or body.name == "samurai":
		samurai = body
		print("Ojo detecta al samurai")

func _on_detection_body_exited(body):
	if body == samurai:
		samurai = null
		print("El samurai escapó del ojo")

# --- DAÑO Y MUERTE ---
func _on_area_muerte_entered(area):
	if area.name == "AreaAtaque" or area.is_in_group("ataque_jugador"):
		recibir_danio()

func recibir_danio():
	morir()

func morir():
	timer_flying_eye.stop()
	# Desactivamos colisiones usando set_deferred para evitar errores de física
	col_flying_eye.set_deferred("disabled", true)
	if has_node("area_deteccion"):
		$area_deteccion.set_deferred("monitoring", false)

	if ani_flying_eye.sprite_frames.has_animation("death"):
		ani_flying_eye.play("death")
		await ani_flying_eye.animation_finished

	queue_free()

func _lanzar_proyectil():
	# Solo lanza si tiene a alguien a quien disparar
	if not samurai or not proyectil_scene:
		return

	var proyectil = proyectil_scene.instantiate()
	get_tree().current_scene.add_child(proyectil)
	proyectil.global_position = mark_flying_eye.global_position
	proyectil.iniciar(Vector2.DOWN)

	ani_flying_eye.play("attack")
