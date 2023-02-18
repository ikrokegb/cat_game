extends Area2D

export(NodePath) onready var target = get_node(target)
export(NodePath) onready var hud = get_node(hud)
var isOverDoor := false
var isLocked := true
var player
var teleportState := 0
onready var sprite = $AnimatedSprite

func _on_door_body_entered(body):
	isOverDoor = true
	player = body

func _on_door_body_exited(body):
	isOverDoor = false


func _on_nearDoor_body_entered(body):
	if hud.hasKey and isLocked:
		$AnimatedSprite.play("closed")
		isLocked = false
		

func _physics_process(delta):
	if isOverDoor and hud.hasKey and Input.is_action_just_pressed("down"):
		$AnimatedSprite.play("open")
		player.state = player.States.FROZEN
		player.set_collision_layer_bit(0, false)
		$soundUnlock.play()
		target.isLocked = false
		teleportState = 0
		$Timer_teleport.start()
		
		
	elif isOverDoor and Input.is_action_just_pressed("down"):
		$soundLocked.play()


func teleport():
	match teleportState:
		0:
			player.visible = false
		1:
			player.position = target.position
			player.get_node("Camera2D").reset_smoothing()
		2:
			target.sprite.play("open")
		3:
			player.visible = true
			player.set_collision_layer_bit(0, true)
			player.state = player.States.FLOOR
		4:
			sprite.play("closed")
			target.sprite.play("closed")
			$Timer_teleport.stop()
	teleportState += 1
