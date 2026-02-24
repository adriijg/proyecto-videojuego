extends Area2D

@onready var anim = $sprt_cofre
var opened = false

func _on_body_entered(body: Node2D) -> void:
	if opened:
		return

	if body.is_in_group("samurai"):
		opened = true
		anim.play("black_chest")
		await anim.animation_finished
		get_tree().change_scene_to_file("res://nivel2/nivel_medio.tscn")
