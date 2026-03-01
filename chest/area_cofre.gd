extends Area2D

@onready var anim = $sprt_cofre
@onready var lbl_mensaje = $lbl_mensaje # ✅ Referencia al nuevo texto
@export var fotos_necesarias: int = 3 
var opened = false

func _on_body_entered(body: Node2D) -> void:
	if opened: return
	if not body.is_in_group("samurai"): return
	
	if Global.fotos_recogidas.size() >= fotos_necesarias:
		abrir_cofre()
	else:
		mostrar_advertencia()

func mostrar_advertencia():
	# Si ya se está mostrando, no hacemos nada para no solapar
	if lbl_mensaje.visible: return
	
	lbl_mensaje.visible = true
	lbl_mensaje.modulate.a = 0 # Empezamos invisible (transparente)
	
	# Animación suave de aparición y desaparición
	var t = create_tween()
	t.tween_property(lbl_mensaje, "modulate:a", 1.0, 0.3) # Aparece en 0.3s
	t.tween_interval(1.5) # Se queda estático 1.5s
	t.tween_property(lbl_mensaje, "modulate:a", 0.0, 0.5) # Desaparece en 0.5s
	t.set_trans(Tween.TRANS_SINE)
	
	await t.finished
	lbl_mensaje.visible = false

func abrir_cofre():
	opened = true
	lbl_mensaje.visible = false 
	anim.play("black_chest")
	await anim.animation_finished
	
	# ✅ El "Switch" ahora ocurre aquí automáticamente
	Global.ir_al_siguiente_nivel()
