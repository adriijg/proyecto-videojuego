extends StaticBody2D

@export var bomba_scene: PackedScene
@export var cadencia: float = 2.0
@export var vida: int = 2 # Añadimos la salud aquí
var samurai = null

@onready var ani_goblin = $ani_goblin
@onready var mark_goblin = $mark_goblin
@onready var timer_goblin = $timer_goblin
# Referencias a los nodos de colisión y muerte
@onready var area_muerte = $area_muerte
@onready var col_goblin = $col_goblin

func _ready():
	timer_goblin.wait_time = cadencia
	timer_goblin.timeout.connect(_lanzar_bomba)
	timer_goblin.start()
	
	samurai = get_tree().get_first_node_in_group("samurai")
	ani_goblin.play("attack")
	
	# CONEXIÓN DE DAÑO: Sin tocar nada de lo anterior
	if area_muerte:
		area_muerte.area_entered.connect(_on_area_muerte_entered)

func _on_area_muerte_entered(area):
	# Detecta el AreaAtaque del samurai
	if area.name == "AreaAtaque" or area.is_in_group("ataque_jugador"):
		recibir_danio()

func recibir_danio():
	vida -= 1
	if vida <= 0:
		morir()
	else:
		# Feedback visual: el goblin se pone rojo un instante
		var t = create_tween()
		t.tween_property(ani_goblin, "modulate", Color.RED, 0.1)
		t.tween_property(ani_goblin, "modulate", Color.WHITE, 0.1)

func morir():
	# 1. Paramos el Timer para que no salgan más bombas
	timer_goblin.stop()
	
	# 2. Desactivamos colisiones para que no estorbe al morir
	col_goblin.set_deferred("disabled", true)
	area_muerte.set_deferred("monitoring", false)
	
	# 3. Animación de alma saliendo
	if ani_goblin.sprite_frames.has_animation("death_soul"):
		ani_goblin.play("death_soul")
		await ani_goblin.animation_finished
	
	# 4. Desaparece del mapa
	queue_free()

func _lanzar_bomba():
	# Si está muerto, no dispares
	if vida <= 0 or not samurai or not bomba_scene:
		return
	
	var bomba = bomba_scene.instantiate()
	get_tree().current_scene.add_child(bomba)
	bomba.global_position = mark_goblin.global_position
	
	var direccion = (samurai.global_position - mark_goblin.global_position).normalized()
	bomba.iniciar(direccion)
	
	ani_goblin.play("attack")
	ani_goblin.animation_finished.connect(_idle_despues_disparo, CONNECT_ONE_SHOT)

func _idle_despues_disparo():
	# Solo vuelve a la animación si sigue vivo
	if vida > 0:
		ani_goblin.play("attack")
