extends StaticBody2D

@export var bomba_scene: PackedScene
@export var cadencia: float = 2.0
@export var vida: int = 2  # ✅ 2 GOLPES
var samurai = null
var samurai_en_rango: bool = false
var ultimo_golpe: float = 0.0
var muerto: bool = false  # 🆕 Evita interferencia

@onready var ani_goblin = $ani_goblin
@onready var mark_goblin = $mark_goblin
@onready var timer_goblin = $timer_goblin
@onready var area_deteccion = $area_deteccion
@onready var col_goblin = $col_goblin

func _ready():
	timer_goblin.wait_time = cadencia
	timer_goblin.timeout.connect(_lanzar_bomba)
	
	samurai = get_tree().get_first_node_in_group("samurai")
	
	# 🟢 FIX SIMPLE - Sprite ESTÁTICO perfecto
	ani_goblin.animation = "attack"     # Selecciona animación
	ani_goblin.frame = 0                # Primer frame (visible)
	ani_goblin.stop()                   # PARA animación
	
	if area_deteccion:
		area_deteccion.body_entered.connect(_on_detection_body_entered)
		area_deteccion.body_exited.connect(_on_detection_body_exited)


func _process(delta):
	if muerto:  # 🆕 NO interfiere con muerte
		return
	
	if samurai_en_rango and samurai and vida > 0:
		# Detecta ataque del samurai
		if samurai.get("atacando") == true:
			var ahora = Time.get_ticks_msec() / 1000.0
			if ahora - ultimo_golpe > 0.5:
				recibir_danio()
				ultimo_golpe = ahora
		
		# Animación activa
		if not ani_goblin.is_playing():
			ani_goblin.play("attack")
	else:
		ani_goblin.stop()
		ani_goblin.frame = 0

func _on_detection_body_entered(body):
	if body.is_in_group("samurai") or body.name == "samurai":
		samurai = body
		samurai_en_rango = true
		timer_goblin.start()

func _on_detection_body_exited(body):
	if body == samurai:
		samurai_en_rango = false
		timer_goblin.stop()

func recibir_danio():
	vida -= 1
	print("⚔️ GOLPE! Vida:", vida)
	
	if vida <= 0:
		morir()
	else:
		# 1er golpe = ROJO
		var t = create_tween()
		t.tween_property(ani_goblin, "modulate", Color.RED, 0.1)
		t.tween_property(ani_goblin, "modulate", Color.WHITE, 0.1)

func morir():
	muerto = true  # 🆕 PARA TODO
	print("💀 GOBLIN MUERE!")
	
	timer_goblin.stop()
	col_goblin.set_deferred("disabled", true)
	area_deteccion.set_deferred("monitoring", false)
	set_process(false)  # 🆕 PARA _process()
	
	# 🟢 ANIMACIÓN MUERTE FLUIDA
	if ani_goblin.sprite_frames.has_animation("death_soul"):
		ani_goblin.play("death_soul")
		await ani_goblin.animation_finished  # Espera COMPLETA
		print("✨ Death animation TERMINADA")
	
	queue_free()

func _lanzar_bomba():
	if muerto or vida <= 0 or not samurai_en_rango or not samurai or not bomba_scene:
		return
	
	var bomba = bomba_scene.instantiate()
	get_tree().current_scene.add_child(bomba)
	bomba.z_index = 10
	bomba.global_position = mark_goblin.global_position
	
	var direccion = (samurai.global_position - mark_goblin.global_position).normalized()
	bomba.iniciar(direccion)
