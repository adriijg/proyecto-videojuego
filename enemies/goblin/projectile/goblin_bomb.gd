extends Area2D

@export var velocidad_horizontal: float = 120.0
@export var fuerza_arrojo: float = 250.0
var gravedad: float = 500.0
var tiempo_vida: float = 5.0
var vel_x: float = 0.0
var vel_y: float = 0.0

@onready var ani_bomb = $ani_bomb
@onready var col_bomb = $col_bomb
var samurai = null

func _ready():
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	# Busca samurai al inicio
	samurai = get_tree().get_first_node_in_group("samurai")

func iniciar(dir: Vector2):
	vel_x = dir.x * velocidad_horizontal
	vel_y = -fuerza_arrojo  # Salto inicial
	tiempo_vida = 5.0
	ani_bomb.play("explosion")

func _physics_process(delta):
	# PERSEGUIMIENTO: Ajusta dirección hacia samurai
	if samurai and is_instance_valid(samurai):
		var direccion_samurai = (samurai.global_position - global_position).normalized()
		# Gira suavemente hacia samurai
		vel_x = lerp(vel_x, direccion_samurai.x * velocidad_horizontal, 0.05)
		# Mantiene altura pero persigue horizontalmente
	
	# Aplica física parabólica + seguimiento
	position.x += vel_x * delta
	vel_y += gravedad * delta * 0.6
	position.y += vel_y * delta
	
	tiempo_vida -= delta
	if tiempo_vida <= 0:
		explotar()

func _on_body_entered(body):
	if body.is_in_group("samurai"):
		body.morir()
	elif body is StaticBody2D or body is TileMap:
		explotar()
	else:
		explotar()

func _on_area_entered(_area):
	explotar()

func explotar():
	col_bomb.disabled = true
	if ani_bomb.animation != "explosion":
		ani_bomb.play("explosion")
		await ani_bomb.animation_finished
	queue_free()
