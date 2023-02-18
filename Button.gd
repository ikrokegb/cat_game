extends Button

func _ready():
	pass # Replace with function body.




func _on_play_button_pressed():
	OS.set_use_vsync(true)
	Engine.target_fps = 60
	Global.lives = Global.max_lives
	get_tree().change_scene("res://level_1.tscn")
