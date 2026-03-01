extends Control

func _on_btn_start_pressed():
	get_tree().change_scene_to_file("res://niveles/mapa_tutorial/mapa_tutorial.tscn")


func _on_btn_end_pressed():
	get_tree().quit()
 
