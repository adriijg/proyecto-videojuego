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
		
		# LÓGICA DE SUELO:
		# Usamos el rayo derecho si dir es 1, y el izquierdo si dir es -1
		var rayo_activo = ray_r if dir > 0 else ray_l
		
		if rayo_activo.is_colliding():
			velocity.x = dir * speed
			ani.play("walk")
		else:
			velocity.x = 0 # Se frena en el borde para no caer
			ani.play("idle")
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
		atacando = true
		ani.play("hurt") # Usa la animación 'hurt' de tu panel

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
	# Este paso es vital para que el esqueleto recupere el control
	if ani.animation == "attack_1" or ani.animation == "hurt":
		atacando = false
