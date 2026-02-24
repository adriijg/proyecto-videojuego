extends CharacterBody2D

@export var speed = 250
@export var gravity_scale = 2.0 
@export var jump_force = -600

@onready var visual = $Visual
@onready var ani_samurai = $Visual/ani_samurai
@onready var col_normal = $col_samurai_normal
@onready var col_run = $Visual/col_samurai_run
@onready var col_attack = $Visual/col_samurai_attack

# Variable de control para saber si estamos en medio de un tajo
var atacando = false

var cam_samurai  # Para la cámara

func _ready():
	ani_samurai.animation_finished.connect(_on_animation_finished)
	add_to_group("samurai")
	cam_samurai = $cam_samurai
	
# FUNCIÓN QUE FALTA PARA EL COFRE
func desactivar_camara_samurai():
	if cam_samurai:
		cam_samurai.enabled = false
		print("Cámara samurai desactivada")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += 980.0 * delta * gravity_scale
	
	if is_on_floor() and Input.is_action_just_pressed("saltar"):
		velocity.y = jump_force

	var input_axis = Input.get_axis("mover_izquierda", "mover_derecha")
	
	# Si estamos atacando, el personaje se detiene
	if atacando:
		velocity.x = move_toward(velocity.x, 0, speed)
	else:
		velocity.x = input_axis * speed
	
	move_and_slide()
	update_animation(input_axis)
	update_col()

func update_animation(input_axis):
	# 1. SI SE PULSA EL BOTÓN Y NO ESTAMOS ATACANDO YA
	if Input.is_action_pressed("atacar") and not atacando:
		iniciar_ataque()
		return

	# 2. BLOQUEO MIENTRAS ATACA
	if atacando:
		return

	# 3. MOVIMIENTO NORMAL
	if input_axis != 0:
		visual.scale.x = 1 if input_axis > 0 else -1
		if is_on_floor():
			ani_samurai.play("run")
	elif is_on_floor():
		ani_samurai.play("idle")

func iniciar_ataque():
	atacando = true
	ani_samurai.play("attack")

func _on_animation_finished():
	if ani_samurai.animation == "attack":
		# Si al terminar la animación SIGUE pulsado, encadenamos otro
		if Input.is_action_pressed("atacar"):
			ani_samurai.play("attack")
		else:
			# Si soltó el botón, liberamos el movimiento
			atacando = false
			ani_samurai.play("idle")

func update_col():
	# Si atacando es true, la colisión de ataque se activa
	col_normal.disabled = false
	col_run.disabled = (ani_samurai.animation != "run")
	col_attack.disabled = not atacando or (ani_samurai.animation != "attack")
