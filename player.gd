extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@export var HEALTH:int = 100

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_running = false
var is_jumping = false
var is_dying = false
var is_dead = false
func _ready():
	$playerAnimations.play("static")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_jumping = true
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		is_running = true		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		is_running = false
	animationHandler(direction)		
	move_and_slide()

func animationHandler(direction):
	if direction < 0:
		$Sprite2D.flip_h = true
	if direction > 0:
		$Sprite2D.flip_h = false

	if not is_dead:
		if HEALTH <= 0 and is_dying:
			$playerAnimations.play("death")
		elif is_jumping and not is_on_floor():
			$playerAnimations.play("jump")
		elif not is_jumping and not is_on_floor():
			$playerAnimations.play("falling")
		elif is_running and is_on_floor():
			$playerAnimations.play("running")
		else:
			$playerAnimations.play("static")



func _on_death_timer_timeout():
	HEALTH = 0
	is_dying = true

func _on_player_animations_animation_finished(anim_name):
	if anim_name == "death":
		$playerAnimations.stop()
		is_dying = false
		is_dead = true
		$Sprite2D.frame = 51
	if anim_name == "jump":
		is_jumping = false
