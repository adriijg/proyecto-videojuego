extends Node2D

func _ready():
	print("🎉 Victoria! Esperando 4 segundos...")
	
	# Timer automático 4 segundos → Menú
	await get_tree().create_timer(4.0).timeout
	print("✅ 4 segundos → Volviendo al menú")
	get_tree().change_scene_to_file("res://menu/menu.tscn")
