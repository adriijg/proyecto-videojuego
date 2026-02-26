extends Area2D

@export var velocidad_caida: float = 300.0
var tiempo_vida: float = 5.0
var direccion: Vector2 = Vector2.DOWN
var dano_continuo_activo: bool = false
var samurai_contacto: Node2D = null

@onready var ani_proyectil = $ani_flying_eye_project
@onready var col_proyectil = $col_flying_eye_project
@onready var ray_suelo = $ray_flying_eye_project

func _ready():
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	ani_proyectil.play("")

func iniciar(dir: Vector2):
	direccion = dir.normalized()
	tiempo_vida = 5.0

func _physics_process(delta):
	# Movimiento vertical descendente
	position += direccion * velocidad_caida * delta

	# Detecta suelo
	if ray_suelo.is_colliding():
		explotar()

	tiempo_vida -= delta
	if tiempo_vida <= 0:
		explotar()

func _on_body_entered(body):
	if body.is_in_group("samurai") or body.name == "samurai":
		samurai_contacto = body
		dano_continuo_activo = true
		# Daño inicial fuerte
		if samurai_contacto.has_method("recibir_danio"):
			samurai_contacto.recibir_danio(1)
	else:
		explotar()

func _on_area_entered(_area):
	explotar()

# ✅ DAÑO CONTINUO SOLO CUANDO TOCA SAMURAI
func _process(delta):
	if dano_continuo_activo and samurai_contacto and is_instance_valid(samurai_contacto):
		if samurai_contacto.has_method("recibir_danio"):
			samurai_contacto.recibir_danio(0.05)  # Daño MUY pequeño continuo
	# ❌ ELIMINADO: else: explotar()

func explotar():
	dano_continuo_activo = false
	col_proyectil.set_deferred("disabled", true)
	ray_suelo.set_deferred("enabled", false)
	
	if ani_proyectil.animation != "projectile":
		ani_proyectil.play("projectile")
		await ani_proyectil.animation_finished
	
	queue_free()
