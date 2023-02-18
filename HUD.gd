extends CanvasLayer

var diamonds = 0
onready var key = $key
var hasKey := false

func _ready():
	$diamonds.text = String(diamonds)
	load_hearts()
	Global.hud = self


func _on_diamond_collected():
	diamonds = diamonds + 1
	_ready()
	if diamonds == 3:
		get_tree().change_scene("res://win_screen.tscn")

func load_hearts():
	$hurtsFull.rect_size.x = Global.lives * 53
	$hurtsEmpty.rect_size.x = (Global.max_lives - Global.lives) * 53
	$hurtsEmpty.rect_position.x = $hurtsFull.rect_position.x + $hurtsFull.rect_size.x * $hurtsFull.rect_scale.x
