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

# CORRECCIÓN DE RUTA: 
# Según tu imagen, AreaAtaqueEnemigo está dentro de AttackArea.
@onready var area_golpe = $Visual/AttackArea/AreaAtaqueEnemigo
@onready var col_golpe = $Visual/AttackArea/AreaAtaqueEnemigo/CollisionShape2D

func _physics_process(delta):
	if muerto: return 

	if not is_on_floor():
		velocity.y += 980 * delta

	if player and not atacando:
		var dir = sign(player.global_position.x - global_position.x)
		visual.scale.x = dir
		
		if ray_r.is_colliding():
			velocity.x = dir * speed
			ani.play("walk")
		else:
			velocity.x = 0
			ani.play("idle")
		
		var rayo_activo = ray_r
	else:
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
		atacando = true
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
	if body.is_in_group("samurai"):
		player = body

func _on_detection_area_body_exited(body):
	if body == player:
		player = null

func _on_attack_area_body_entered(body):
	# Esta señal debe venir del Area2D grande (AttackArea)
	if body.is_in_group("samurai") and not atacando and not muerto:
		iniciar_ataque_esqueleto()

func iniciar_ataque_esqueleto():
	print("1. Intento atacar") # Si esto sale, la señal de detección funciona.
	atacando = true
	ani.play("attack_1")
	
	await get_tree().create_timer(0.4).timeout 
	
	var cuerpos = area_golpe.get_overlapping_bodies()
	print("2. Cuerpos detectados: ", cuerpos.size()) # Si sale 0, el problema es la MASK o MONITORING.
	
	for cuerpo in cuerpos:
		print("3. He tocado a: ", cuerpo.name) # Si sale el nombre pero no quita vida, el problema es el GRUPO.
		if cuerpo.is_in_group("samurai"):
			cuerpo.recibir_danio(1)

func _on_ani_skeleton_animation_finished():
	if ani.animation == "attack_1" or ani.animation == "hurt":
		atacando = false 
		ani.play("idle")
