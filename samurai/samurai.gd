extends CharacterBody2D

@export var speed = 250
@export var gravity_scale = 2.0 
@export var jump_force = -600
@export var vida_max = 3

@onready var visual = $Visual
@onready var ani_samurai = $Visual/ani_samurai
@onready var col_normal = $col_samurai_normal
@onready var col_run = $Visual/col_samurai_run
@onready var col_attack = $Visual/AreaAtaque/col_samurai_attack
@onready var area_ataque = $Visual/AreaAtaque
@onready var particles = $Visual/muerte_particulas
@onready var health_bar = $hud/life_bar # Asegúrate de que la ruta sea correcta

var atacando = false
var cam_samurai 
var vida_actual = 3
var esta_muerto = false

func _ready():
	if not ani_samurai.animation_finished.is_connected(_on_animation_finished):
		ani_samurai.animation_finished.connect(_on_animation_finished)
	add_to_group("samurai")
	cam_samurai = $cam_samurai

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += 980.0 * delta * gravity_scale
	
	if is_on_floor() and Input.is_action_just_pressed("saltar"):
		velocity.y = jump_force

	var input_axis = Input.get_axis("mover_izquierda", "mover_derecha")
	
	if atacando:
		velocity.x = move_toward(velocity.x, 0, speed)
	else:
		velocity.x = input_axis * speed
	
	move_and_slide()
	update_animation(input_axis)
	update_col()

func update_animation(input_axis):
	# Usamos is_action_just_pressed para no atacar mil veces por segundo
	if Input.is_action_just_pressed("atacar") and not atacando:
		iniciar_ataque()
		return

	if atacando: return

	if input_axis != 0:
		visual.scale.x = 1 if input_axis > 0 else -1
		if is_on_floor(): ani_samurai.play("run")
	elif is_on_floor():
		ani_samurai.play("idle")

func iniciar_ataque():
	if atacando: return
	atacando = true
	ani_samurai.play("attack")
	
	# 1. ACTIVAMOS la hitbox físicamente
	col_attack.disabled = false 
	
	# 2. Esperamos un instante para que el dibujo de la espada coincida con el golpe
	await get_tree().create_timer(0.1).timeout
	
	# 3. COMPROBACIÓN: ¿Hay enemigos dentro del área ahora que está activa?
	var cuerpos = area_ataque.get_overlapping_bodies()
	for cuerpo in cuerpos:
		if cuerpo.has_method("recibir_danio") and cuerpo != self:
			cuerpo.recibir_danio(1)
			print("¡Hitbox activa y golpeando a: ", cuerpo.name, "!")
	
	# 4. OPCIONAL: Puedes desactivarla aquí o dejar que update_col lo haga al terminar
	
func recibir_danio(cantidad):
	vida_actual -= cantidad
	
	# Actualizamos visualmente la barra de vida
	if health_bar.has_method("set_value"):
		health_bar.value = vida_actual
	
	# Si la vida llega a cero, activamos las partículas
	if vida_actual <= 0:
		morir()
	else:
		# Opcional: Pequeño parpadeo rojo para avisar del golpe
		ani_samurai.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		ani_samurai.modulate = Color.WHITE
	
func morir():
	if particles: # Primero comprobamos si el nodo existe
		particles.emitting = true

	ani_samurai.visible = false
	set_physics_process(false)

	await get_tree().create_timer(1.5).timeout
	get_tree().reload_current_scene()

func _on_animation_finished():
	if ani_samurai.animation == "attack":
		atacando = false
		ani_samurai.play("idle")

func update_col():
	# Tu lógica original para activar la hitbox
	col_normal.disabled = false
	if col_run: col_run.disabled = (ani_samurai.animation != "run")
	# col_attack se activa SOLAMENTE cuando atacamos
	if col_attack: col_attack.disabled = not atacando
