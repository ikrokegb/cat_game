extends Area2D

export(NodePath) onready var hud = get_node(hud)

func _on_key_body_entered(body):
	visible = false
	set_collision_mask_bit(0, false)
	$SoundKey.play()
	hud.key.texture = load("res://ASSETS/SPRITES/panel/key.png")
	hud.hasKey = true


func _on_SoundKey_finished():
	queue_free()
