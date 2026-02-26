extends CharacterBody2D

@export var vida = 2
@export var speed = 50.0

var player = null
var atacando = false
var muerto = false

@onready var ani = $Visual/ani_skeleton
@onready var visual = $Visual
@onready var ray_r = $Visual/ray_right
@onready var ray_l = $Visual/ray_left

# Rutas actualizadas según tu jerarquía
@onready var area_golpe = $Visual/AreaAtaqueEnemigo
@onready var col_golpe = $Visual/AreaAtaqueEnemigo/col_ataque_ske

func _physics_process(delta):
	if muerto: return 
	
	if not player or atacando:
		velocity.x = move_toward(velocity.x, 0, speed) # Esto frena al esqueleto en seco

	if not is_on_floor():
		velocity.y += 980 * delta

	# LÓGICA DE ATAQUE CONTINUO
	if player and not atacando:
		# Comprobamos si el samurai sigue dentro del área de ataque
		var cuerpos_en_rango = area_golpe.get_overlapping_bodies()
		var samurai_cerca = false
		for c in cuerpos_en_rango:
			if c.name == "samurai":
				samurai_cerca = true
				break
		
		if samurai_cerca:
			# Si está cerca y no estamos atacando, inicia el ataque
			iniciar_ataque_esqueleto()
		else:
			# Si está en el área de detección pero no en la de ataque, camina hacia él
			var dir = sign(player.global_position.x - global_position.x)
			visual.scale.x = dir
			
			if ray_r.is_colliding():
				velocity.x = dir * speed
				ani.play("walk")
			else:
				velocity.x = 0
				ani.play("idle")
	else:
		# Si no hay jugador o estamos en medio de un ataque/daño
		velocity.x = move_toward(velocity.x, 0, speed)
		if not atacando:
			ani.play("idle")

	move_and_slide()

func recibir_danio(cantidad):
	if muerto: return
	vida -= cantidad
	if vida <= 0:
		morir()
	else:
		atacando = true # Bloquea el movimiento mientras recibe daño
		ani.play("hurt")

func morir():
	muerto = true
	velocity = Vector2.ZERO
	ani.play("death")
	$col_skeleton_normal.set_deferred("disabled", true)
	await ani.animation_finished
	queue_free()

# --- SEÑALES ---

func _on_detection_area_body_entered(body):
	if body.name == "samurai":
		player = body

func _on_detection_area_body_exited(body):
	if body == player:
		player = null

# Esta señal inicia el primer ataque al entrar
func _on_area_ataque_enemigo_body_entered(body):
	if body.name == "samurai" and not atacando and not muerto:
		iniciar_ataque_esqueleto()

func iniciar_ataque_esqueleto():
	atacando = true
	ani.play("attack_1")
	
	# Esperamos al frame del impacto visual
	await get_tree().create_timer(0.4).timeout 
	
	if not muerto and area_golpe:
		var cuerpos = area_golpe.get_overlapping_bodies()
		for cuerpo in cuerpos:
			if cuerpo.name == "samurai":
				cuerpo.recibir_danio(1) # Actualiza el HUD del Samurai
				print("¡DAÑO REALIZADO AL SAMURAI!")

func _on_ani_skeleton_animation_finished():
	# Al terminar la animación, permitimos que el esqueleto decida qué hacer en el siguiente frame
	if ani.animation == "attack_1" or ani.animation == "hurt":
		atacando = false 
		# No ponemos ani.play("idle") aquí para que el physics_process pueda elegir "attack_1" inmediatamente si sigues ahí
