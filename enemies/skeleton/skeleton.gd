extends CharacterBody2D

@export var vida = 2
@export var speed = 50.0

var player = null
var atacando = false
var muerto = false

@onready var ani = $Visual/ani_skeleton
@onready var visual = $Visual

# Referencias correctas a tus rayos dentro de Visual
@onready var ray_r = $Visual/ray_right
@onready var ray_l = $Visual/ray_left

func _physics_process(delta):
	if muerto: return 

	if not is_on_floor():
		velocity.y += 980 * delta

	if player and not atacando:
		var dir = sign(player.global_position.x - global_position.x)
		
		# Invertimos el scale.x para que el esqueleto mire al jugador
		# y los rayos giren con él
		visual.scale.x = dir
		
		# Usamos siempre el mismo porque al estar en el centro 
		# y dentro de Visual, siempre apuntará hacia abajo del esqueleto.
		if ray_r.is_colliding():
			velocity.x = dir * speed
			ani.play("walk")
		else:
			velocity.x = 0
			ani.play("idle")
		
		# LÓGICA DE SUELO:# Sustituye tu lógica de rayos por esta:
		var rayo_activo
		if dir > 0:
			# Si voy a la derecha y el cuerpo mira a la derecha, 
			# el que está delante es el que pusiste a la derecha (ray_r)
			rayo_activo = ray_r 
		else:
			# Si voy a la izquierda y el cuerpo mira a la izquierda,
			# por el efecto espejo, el que ahora está delante es el ray_r también
			# (o el ray_l según cómo los posicionaste)
			rayo_activo = ray_r
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		if not atacando:
			ani.play("idle")

	move_and_slide()

func recibir_danio(cantidad):
	if muerto: return
	
	vida -= cantidad
	print("Vida esqueleto: ", vida)
	
	if vida <= 0:
		morir()
	else:
		# Al recibir un golpe, activamos 'atacando' para que no camine
		# mientras hace la animación de dolor (hurt)
		atacando = true
		ani.play("hurt")

func morir():
	muerto = true
	velocity = Vector2.ZERO
	ani.play("death") # Usa 'death' de tu panel
	# Desactivamos la colisión principal (la cápsula)
	$col_skeleton_normal.set_deferred("disabled", true)
	
	await ani.animation_finished
	queue_free()

# --- SEÑALES (Conéctalas en el panel 'Nodo') ---

func _on_detection_area_body_entered(body):
	if body.name == "samurai":
		player = body

func _on_detection_area_body_exited(body):
	if body == player:
		player = null

func _on_attack_area_body_entered(body):
	if body.name == "samurai" and not atacando and not muerto:
		atacando = true
		ani.play("attack_1") # Usa 'attack_1' de tu panel

func _on_ani_skeleton_animation_finished():
	# IMPORTANTE: Esta función debe "liberar" al esqueleto 
	# tanto si termina de atacar como si termina de dolerse.
	if ani.animation == "attack_1" or ani.animation == "hurt":
		atacando = false # <--- Aquí es donde deja de estar "tonto"
