extends StaticBody2D

@export var bomba_scene: PackedScene
@export var cadencia: float = 2.0
var samurai = null

@onready var ani_goblin = $ani_goblin
@onready var mark_goblin = $mark_goblin
@onready var timer_goblin = $timer_goblin

func _ready():
	timer_goblin.wait_time = cadencia
	timer_goblin.timeout.connect(_lanzar_bomba)
	timer_goblin.start()
	
	samurai = get_tree().get_first_node_in_group("samurai")
	ani_goblin.play("attack")

func _lanzar_bomba():
	if not samurai or not bomba_scene:
		return
	
	var bomba = bomba_scene.instantiate()
	get_tree().current_scene.add_child(bomba)
	bomba.global_position = mark_goblin.global_position
	
	var direccion = (samurai.global_position - mark_goblin.global_position).normalized()
	bomba.iniciar(direccion)
	
	ani_goblin.play("attack")
	ani_goblin.animation_finished.connect(_idle_despues_disparo, CONNECT_ONE_SHOT)

func _idle_despues_disparo():
	ani_goblin.play("attack")
