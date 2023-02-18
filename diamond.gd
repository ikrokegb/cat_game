extends Area2D

signal diamond_collected


func _on_diamond_body_entered(body):
	$AnimationPlayer.play("bounce")
	body.add_diamond()
	emit_signal("diamond_collected")
	set_collision_mask_bit(0, false)
	$collect_diamond_sound.play()

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
