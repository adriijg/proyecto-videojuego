extends StaticBody2D

@export var bomba_scene: PackedScene
@export var cadencia: float = 2.0
@export var vida: int = 2  # ← 2 ataques = muerte (como esqueleto)
var samurai = null
var samurai_en_rango: bool = false
var muerto: bool = false

@onready var ani_goblin = $ani_goblin
@onready var mark_goblin = $mark_goblin
@onready var timer_goblin = $timer_goblin
@onready var area_deteccion = $area_deteccion
@onready var col_goblin = $col_goblin
@onready var area_daño = $area_daño  # ← NUEVO: Area2D para daño

func _ready():
	timer_goblin.wait_time = cadencia
	timer_goblin.timeout.connect(_lanzar_bomba)
	
	samurai = get_tree().get_first_node_in_group("samurai")
	
	# Goblin estático al inicio
	ani_goblin.animation = "attack"
	ani_goblin.frame = 0
	ani_goblin.stop()
	
	# Rango detección (grande)
	if area_deteccion:
		area_deteccion.body_entered.connect(_on_detection_body_entered)
		area_deteccion.body_exited.connect(_on_detection_body_exited)
	
	# ✅ COMO ESQUELETO: Área daño detecta espada
	if area_daño:
		area_daño.area_entered.connect(_on_recibir_ataque_samurai)  # ← CLAVE

func _process(delta):
	if muerto:
		return
	
	# Solo animación (SIN daño aquí)
	if samurai_en_rango and vida > 0:
		if not ani_goblin.is_playing():
			ani_goblin.play("attack")
	else:
		ani_goblin.stop()
		ani_goblin.frame = 0

# ✅ IGUAL QUE ESQUELETO: Detecta área espada del samurai
func _on_recibir_ataque_samurai(area):
	if area.name == "AreaAtaque" or area.is_in_group("ataque_jugador"):
		recibir_danio(1)

func recibir_danio(cantidad):
	if muerto: 
		return  # ← IGUAL QUE ESQUELETO
	
	vida -= cantidad
	print("⚔️ GOBLIN! Vida restante:", vida)
	
	if vida <= 0:
		morir()
	else:
		# ✅ IGUAL QUE ESQUELETO: hurt + rojo
		var t = create_tween()
		t.tween_property(ani_goblin, "modulate", Color.RED, 0.1)
		t.tween_property(ani_goblin, "modulate", Color.WHITE, 0.1)

func morir():
	muerto = true
	print("💀 GOBLIN MUERTO!")
	
	timer_goblin.stop()
	col_goblin.set_deferred("disabled", true)
	area_deteccion.set_deferred("monitoring", false)
	
	if ani_goblin.sprite_frames.has_animation("death_soul"):
		ani_goblin.play("death_soul")
		await ani_goblin.animation_finished
	
	queue_free()

func _on_detection_body_entered(body):
	if body.is_in_group("samurai") or body.name == "samurai":
		samurai = body
		samurai_en_rango = true
		timer_goblin.start()

func _on_detection_body_exited(body):
	if body == samurai:
		samurai_en_rango = false
		timer_goblin.stop()

func _lanzar_bomba():
	if muerto or vida <= 0 or not samurai_en_rango or not samurai or not bomba_scene:
		return
	
	var bomba = bomba_scene.instantiate()
	get_tree().current_scene.add_child(bomba)
	bomba.z_index = 10
	bomba.global_position = mark_goblin.global_position
	
	var direccion = (samurai.global_position - mark_goblin.global_position).normalized()
	bomba.iniciar(direccion)
