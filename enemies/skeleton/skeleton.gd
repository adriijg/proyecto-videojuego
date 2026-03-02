extends CharacterBody2D

@export var vida = 3
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

func _ready():
	# IMPORTANTE: Conecta el área que recibe daño del samurai
	# Si tu nodo se llama "area_muerte" como el del goblin, usa ese nombre
	if has_node("area_muerte"):
		$area_muerte.area_entered.connect(_on_recibir_ataque_jugador)

func _physics_process(delta):
	if muerto: return 
	
	if not player or atacando:
		velocity.x = move_toward(velocity.x, 0, speed)

	if not is_on_floor():
		velocity.y += 980 * delta

	if player and not atacando:
		var cuerpos_en_rango = area_golpe.get_overlapping_bodies()
		var samurai_cerca = false
		for c in cuerpos_en_rango:
			if c.name == "samurai":
				samurai_cerca = true
				break
		
		if samurai_cerca:
			iniciar_ataque_esqueleto()
		else:
			var dir = sign(player.global_position.x - global_position.x)
			visual.scale.x = dir
			
			if ray_r.is_colliding():
				velocity.x = dir * speed
				ani.play("walk")
			else:
				velocity.x = 0
				ani.play("idle")
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		if not atacando:
			ani.play("idle")

	move_and_slide()

# Función que se activa cuando la espada del samurai toca al esqueleto
func _on_recibir_ataque_jugador(area):
	if area.name == "AreaAtaque" or area.is_in_group("ataque_jugador"):
		recibir_danio(1) # Descuenta 1 de vida

func recibir_danio(cantidad):
	if muerto: return
	vida -= cantidad
	print("Vida esqueleto: ", vida)
	
	if vida <= 0:
		morir()
	else:
		atacando = true 
		ani.play("hurt")
		# Feedback visual para saber que le hemos dado
		var t = create_tween()
		t.tween_property(visual, "modulate", Color.RED, 0.1)
		t.tween_property(visual, "modulate", Color.WHITE, 0.1)

func morir():
	Global.reproducir_muerte_monstruo()
	ani.play("death")
	
	visible = false
	
	$col_skeleton_normal.set_deferred("disabled", true)
	
	await get_tree().create_timer(0.6).timeout
	
	muerto = true
	velocity = Vector2.ZERO
	
	
	await ani.animation_finished
	
	queue_free()

# --- SEÑALES ---

func _on_detection_area_body_entered(body):
	if body.name == "samurai":
		player = body

func _on_detection_area_body_exited(body):
	if body == player:
		player = null

func _on_area_ataque_enemigo_body_entered(body):
	if body.name == "samurai" and not atacando and not muerto:
		iniciar_ataque_esqueleto()

func iniciar_ataque_esqueleto():
	atacando = true
	ani.play("attack_1")
	
	await get_tree().create_timer(0.4).timeout 
	
	if not muerto and area_golpe:
		var cuerpos = area_golpe.get_overlapping_bodies()
		for cuerpo in cuerpos:
			if cuerpo.name == "samurai":
				cuerpo.recibir_danio(1)
				print("¡DAÑO REALIZADO AL SAMURAI!")

func _on_ani_skeleton_animation_finished():
	if ani.animation == "attack_1" or ani.animation == "hurt":
		atacando = false
