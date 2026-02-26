extends Area2D

@export var proyectil_scene: PackedScene
@export var cadencia: float = 2.0
@export var velocidad_seguimiento: float = 100.0
@export var vida: int = 1  # Muere de 1 golpe

var posicion_y_fija: float
var samurai: Node2D = null

@onready var ani_flying_eye = $ani_flying_eye
@onready var mark_flying_eye = $mark_flying_eye
@onready var timer_flying_eye = $timer_flying_eye
@onready var col_flying_eye = $col_flying_eye
@onready var area_muerte = $area_muerte

func _ready():
	posicion_y_fija = global_position.y
	
	timer_flying_eye.wait_time = cadencia
	timer_flying_eye.timeout.connect(_lanzar_proyectil)
	timer_flying_eye.start()

	samurai = get_tree().get_first_node_in_group("samurai")
	ani_flying_eye.play("attack")

	# ✅ CAMBIO CLAVE: body_entered en lugar de area_entered
	if area_muerte:
		area_muerte.body_entered.connect(_on_body_entered)  # ← AQUÍ ESTÁ EL FIX

func _physics_process(delta):
	if samurai and is_instance_valid(samurai):
		var diff_x = samurai.global_position.x - global_position.x
		global_position.x += diff_x * delta * (velocidad_seguimiento / 50.0)
		global_position.y = posicion_y_fija

# ✅ CAMBIADO: Ahora detecta CUERPOS (CharacterBody2D del samurai)
func _on_body_entered(body):
	if body.is_in_group("samurai") or body.name == "samurai":
		recibir_danio()

func recibir_danio():
	morir()  # Muere inmediatamente

func morir():
	timer_flying_eye.stop()
	col_flying_eye.set_deferred("disabled", true)
	area_muerte.set_deferred("monitoring", false)

	if ani_flying_eye.sprite_frames.has_animation("death"):
		ani_flying_eye.play("death")
		await ani_flying_eye.animation_finished

	queue_free()

func _lanzar_proyectil():
	if vida <= 0 or not samurai or not proyectil_scene:
		return

	var proyectil = proyectil_scene.instantiate()
	get_tree().current_scene.add_child(proyectil)
	proyectil.global_position = mark_flying_eye.global_position

	proyectil.iniciar(Vector2.DOWN)

	ani_flying_eye.play("attack")
	ani_flying_eye.animation_finished.connect(_idle_despues_disparo, CONNECT_ONE_SHOT)

func _idle_despues_disparo():
	if vida > 0:
		ani_flying_eye.play("attack")
