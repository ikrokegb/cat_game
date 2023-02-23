extends KinematicBody2D

enum States {AIR = 1, FLOOR = 2, LADDER = 3, WALL = 4, FROZEN}
var state = States.AIR

var velocity = Vector2(0, 0)
var diamonds = 0
var direction = 1
var last_jump_direction = 0
var on_ladder = false
var hurt := 0
const SPEED = 180
const RUNSPEED = 400
const JUMPFORCE = -950
const GRAVITY = 30
const FIREBALL = preload("res://fireball.tscn")

func _physics_process(delta):
	match state:
		States.AIR:
			if is_on_floor() and velocity.y == 0:
				last_jump_direction = 0
				state = States.FLOOR
				continue
			elif is_near_wall():
				state = States.WALL
				continue
			elif should_climb_ladder():
				state = States.LADDER
				continue
			$Sprite.play("jump")
			if Input.is_action_pressed("right"):
				velocity.x = lerp(velocity.x, SPEED, 0.1) if velocity.x < SPEED else lerp(velocity.x, SPEED, 0.03)
				$Sprite.flip_h = false
			elif Input.is_action_pressed("left"):
				velocity.x = lerp(velocity.x, -SPEED, 0.1) if velocity.x > -SPEED else lerp(velocity.x, SPEED, 0.03)
				$Sprite.flip_h = true
				
			else:
				velocity.x = lerp(velocity.x, 0, 0.1)
			set_direction()
			move_and_fall(false)
			fire()
			
		States.FLOOR:
			if not is_on_floor():
				state = States.AIR
			elif should_climb_ladder():
					state = States.LADDER
					continue
					
			if Input.is_action_pressed("right"):
				if Input.is_action_pressed("run"):
					velocity.x = lerp(velocity.x, RUNSPEED, 0.1)
					$Sprite.set_speed_scale(8.0)
				else:
					velocity.x = lerp(velocity.x, SPEED, 0.1)
				$Sprite.play("walk")
				$Sprite.set_speed_scale(6.0)
				$Sprite.flip_h = false
			elif Input.is_action_pressed("left"):
				if Input.is_action_pressed("run"):
					velocity.x = lerp(velocity.x, -RUNSPEED, 0.1)
					$Sprite.set_speed_scale(8.0)
				else:
					velocity.x = lerp(velocity.x, -SPEED, 0.1)
					$Sprite.set_speed_scale(6.0)
				$Sprite.play("walk")
				$Sprite.flip_h = true
			elif Input.is_action_pressed("down"):
				$Sprite.play("press_button")
				velocity.x = 0
			else:
				$Sprite.play("hero")
				velocity.x = lerp(velocity.x, 0, 0.1)
			
			if Input.is_action_just_pressed("jump"):
				velocity.y = JUMPFORCE
				$sound_jump.play()
				state = States.AIR

			set_direction()
			move_and_fall(false)
			fire()
			
		States.WALL:
			if is_on_floor():
				last_jump_direction = 0
				state = States.FLOOR
				continue
			elif not is_near_wall():
				state = States.AIR
				continue
			$Sprite.play("wall")
			move_and_fall(true)
			
			if direction != last_jump_direction and Input.is_action_pressed("jump") and ((Input.is_action_pressed("left") and direction == 1) or (Input.is_action_pressed("right") and direction == -1)):
				last_jump_direction = direction
				velocity.x = 450 * -direction
				velocity.y = JUMPFORCE * 0.7
				$sound_jump.play()
				state = States.AIR
				
		States.LADDER:
			if not on_ladder:
				state = States.AIR
				continue
			elif is_on_floor() and Input.is_action_pressed("down") and velocity.y == 0:
				state = States.FLOOR
				Input.action_release("up")
				Input.action_release("down")
				continue
			elif Input.is_action_just_pressed("jump"):
				Input.action_release("down")
				Input.action_release("up")
				velocity.y = JUMPFORCE * 0.7
				state = States.AIR
				continue
			
			if Input.is_action_pressed("down") or Input.is_action_pressed("up") or Input.is_action_pressed("left") or Input.is_action_pressed("right"):
				$Sprite.play("climb")
			else:
				$Sprite.stop()
				
			if Input.is_action_pressed("up"):
				velocity.y = -SPEED
			elif Input.is_action_pressed("down"):
				velocity.y = SPEED
			else:
				velocity.y = lerp(velocity.y, 0, 0.3)
				
			if Input.is_action_pressed("right"):
				velocity.x = SPEED/6
			elif Input.is_action_pressed("left"):
				velocity.x = -SPEED/6
			else:
				velocity.x = lerp(velocity.x, 0, 0.3)
				
			velocity = move_and_slide(velocity, Vector2.UP)
		States.FROZEN:
			pass
			
func should_climb_ladder() -> bool:
	if on_ladder and (Input.is_action_pressed("up") or Input.is_action_pressed("down")):
		return true
	else:
		return false
			
func set_direction():
	direction = 1 if not $Sprite.flip_h else -1
	$wall_checker.rotation_degrees = 90 * -direction
			
func is_near_wall():
	return $wall_checker.is_colliding() and not $wall_checker.get_collider().is_in_group("one_way")

func fire():
	if Input.is_action_just_pressed("fire") and not is_near_wall() and hurt == 0:
		var direction = 1 if not $Sprite.flip_h else -1
		var f = FIREBALL.instance()
		f.direction = direction
		get_parent().add_child(f)
		f.position.y = position.y
		f.position.x = position.x + 30 * direction
	
func move_and_fall(slow_fall: bool):
	velocity.y = velocity.y + GRAVITY
	
	if slow_fall:
		velocity.y = clamp(velocity.y, JUMPFORCE, 200)
		
	velocity = move_and_slide(velocity, Vector2.UP)

func _on_fallzone_body_entered(body):
	Global.lose_life()
	if Global.lives >= 1:
		get_tree().reload_current_scene()
	
	
func bounce():
	velocity.y = JUMPFORCE * 0.7
	
	
func ouch(var enemyposx):
	Global.lose_life()
	
	velocity.y = JUMPFORCE * 0.5

	if position.x < enemyposx:
		velocity.x = -800
	elif position.x > enemyposx:
		velocity.x = 800
		
	Input.action_release("left")
	Input.action_release("right")
	
	set_modulate(Color(10, 10, 10, 0.9))
	set_collision_layer_bit(0, false)
	hurt = 20
	$Timer.start(0.1)
	
	
func add_diamond():
	diamonds = diamonds + 1
	#print("now i have diamonds: ", diamonds)


func _on_Timer_timeout():
	hurt -= 1
	if hurt == 0:
		$Timer.stop()
		set_modulate(Color(1, 1, 1, 1))
		set_collision_layer_bit(0, true)
	else:
		set_modulate(Color(10, 10, 10, 0.9) if hurt % 2 == 0 else Color(1, 1, 1, 0.7))
	#set_modulate(Color(1, 1, 1, 1))


func _on_ladder_checker_body_entered(body):
	on_ladder = true


func _on_ladder_checker_body_exited(body):
	on_ladder = false
