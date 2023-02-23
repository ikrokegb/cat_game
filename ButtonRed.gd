extends StaticBody2D

var onButton := false
signal buttonPushed


func _on_topChecker_body_entered(body):
	onButton = true


func _on_topChecker_body_exited(body):
	onButton = false
	
func _physics_process(delta):
	if onButton and Input.is_action_pressed("down"):
		$AnimatedSprite.play("down")
		$AudioStreamPlayer2D.play()
		onButton = false
		$topChecker.set_collision_mask_bit(0, false)
		$CollisionShapeTop.position.y = -9
		$CollisionShapeTop.shape.radius = 2
		$CollisionShapeTop.shape.height = 34
		emit_signal("buttonPushed") 
