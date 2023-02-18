extends Button

func _ready():
	pass # Replace with function body.



func _on_back_to_menu_Button_pressed():
	Global.lives = Global.max_lives
	get_tree().change_scene("res://titleMenu.tscn")
