extends CharacterBody2D

@export var speed = 500
@export var gravity_scale = 2
@export var jump_force = -700

@onready var visual = $Visual
@onready var ani_samurai = $Visual/ani_samurai
@onready var col_normal = $col_samurai_normal # Ruta corregida a hija directa
@onready var col_run = $Visual/col_samurai_run
@onready var col_attack = $Visual/col_samurai_attack

func _physics_process(delta: float) -> void:
	var input_axis = Input.get_axis("mover_izquierda", "mover_derecha")
	
	if not is_on_floor():
		velocity += get_gravity() * delta * gravity_scale
	
	if is_on_floor() and Input.is_action_just_pressed("saltar"):
		velocity.y = jump_force

	velocity.x = input_axis * speed
	
	move_and_slide()
	update_animation(input_axis)
	update_col()

func update_animation(input_axis):
	if Input.is_action_just_pressed("atacar"):
		ani_samurai.play("atacar")
		return

	if ani_samurai.animation == "atacar" and ani_samurai.is_playing():
		return

	if input_axis != 0:
		# Giramos solo el contenedor visual y las hitboxes de ataque
		visual.scale.x = 1 if input_axis > 0 else -1
		ani_samurai.play("run")
	elif is_on_floor():
		ani_samurai.play("idle")

func update_col():
	var anim = ani_samurai.animation
	
	# La normal siempre activa para pisar el suelo con seguridad
	col_normal.disabled = false
	col_run.disabled = true
	col_attack.disabled = true
	
	if anim == "run":
		# Solo activamos la de correr si es realmente distinta
		col_run.disabled = false
	elif anim == "atacar":
		col_attack.disabled = false
