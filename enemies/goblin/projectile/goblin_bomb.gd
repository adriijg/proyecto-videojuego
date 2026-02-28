extends Area2D

@export var velocidad_horizontal: float = 120.0
@export var fuerza_arrojo: float = 250.0
var gravedad: float = 500.0
var tiempo_vida: float = 5.0
var vel_x: float = 0.0
var vel_y: float = 0.0
var dano_continuo: bool = false
var samurai_contacto = null

@onready var ani_bomb = $ani_bomb
@onready var col_bomb = $col_bomb
@onready var ray_suelo = $ray_suelo
var samurai = null

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	area_entered.connect(_on_area_entered)
	samurai = get_tree().get_first_node_in_group("samurai")
	z_index = 10
	
	# 🆕 FORZAR RayCast CADA FRAME
	if ray_suelo:
		ray_suelo.enabled = true
		ray_suelo.exclude_parent = true

func iniciar(dir: Vector2):
	vel_x = dir.x * velocidad_horizontal
	vel_y = -fuerza_arrojo
	tiempo_vida = 5.0
	ani_bomb.play("explosion")

func _physics_process(delta):
	# Física
	if samurai and is_instance_valid(samurai):
		var direccion_samurai = (samurai.global_position - global_position).normalized()
		vel_x = lerp(vel_x, direccion_samurai.x * velocidad_horizontal, 0.05)
	
	position.x += vel_x * delta
	vel_y += gravedad * delta * 0.6
	position.y += vel_y * delta
	
	# 🆕 RAYCAST FORZADO CADA FRAME
	if ray_suelo:
		ray_suelo.force_raycast_update()  # CRÍTICO
		if ray_suelo.is_colliding():
			print("💥 SUELO DETECTADO: ", ray_suelo.get_collider())
			explotar()
	
	tiempo_vida -= delta
	if tiempo_vida <= 0:
		explotar()

# 🆕 DAÑO INICIAL + CONTINUO
func _on_body_entered(body):
	if body.is_in_group("samurai") or body.name == "samurai":
		samurai_contacto = body
		dano_continuo = true
		# Daño inicial pequeño
		if samurai_contacto.has_method("recibir_danio"):
			samurai_contacto.recibir_danio(0.5)
	else:
		explotar()

# 🆕 PARA daño continuo cuando sale
func _on_body_exited(body):
	if body == samurai_contacto:
		dano_continuo = false
		samurai_contacto = null

func _process(delta):
	# 🆕 DAÑO CONTINUO cada frame (muy poco)
	if dano_continuo and samurai_contacto and is_instance_valid(samurai_contacto):
		if samurai_contacto.has_method("recibir_danio"):
			samurai_contacto.recibir_danio(0.05)  # Daño MUY pequeño por frame

func _on_area_entered(_area):
	explotar()

func explotar():
	dano_continuo = false  # Para daño
	col_bomb.set_deferred("disabled", true)
	if ray_suelo:
		ray_suelo.set_deferred("enabled", false)
	
	if ani_bomb.animation != "explosion":
		ani_bomb.play("explosion")
		await ani_bomb.animation_finished
	
	queue_free()
