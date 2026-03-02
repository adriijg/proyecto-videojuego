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

	# CONEXIÓN CORREGIDA: Nos conectamos a nosotros mismos (el Area2D raíz)
	self.area_entered.connect(_on_area_muerte_entered)
	
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
		print("¡Ojo golpeado!")
		recibir_danio()

func recibir_danio():
	# Evitamos que procese más daño si ya está muriendo
	if vida <= 0: return 
	vida = 0
	print("¡Ojo eliminado!")
	morir()

func morir():
	Global.reproducir_muerte_monstruo()
	# 1. Paramos todo el procesamiento inmediatamente
	set_physics_process(false)
	timer_flying_eye.stop()
	
	# 2. Desactivamos las áreas para que no den más mensajes
	col_flying_eye.set_deferred("disabled", true)
	if has_node("area_deteccion"):
		$area_deteccion.set_deferred("monitoring", false)
		$area_deteccion.set_deferred("monitorable", false)

	# 3. Animación y eliminación
	if ani_flying_eye.sprite_frames.has_animation("death"):
		ani_flying_eye.play("death")
		await ani_flying_eye.animation_finished
	
	# 4. Desaparecer del todo
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
