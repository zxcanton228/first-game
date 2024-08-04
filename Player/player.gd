extends CharacterBody2D

enum {
	IDLE,
	MOVIE,
	ATTACK,
	ATTACK2,
	ATTACK3,
	BLOCK,
	SLIDE
}

const SPEED = 100.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var anim = $AnimatedSprite2D
@onready var animPlayer = $AnimationPlayer

var health = 100
var gold = 0
var state = MOVIE
var run_spped = 2

func _physics_process(delta):
	match state:
		MOVIE:
			movie_state()
		ATTACK:
			attack_state()
		ATTACK2:
			pass
		ATTACK3:
			pass
		BLOCK:
			block_state()
		SLIDE:
			slide_state()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta


	if velocity.y > 0:
		animPlayer.play("Fall")

	if health <= 0:
		health = 0
		animPlayer.play("Death")
		await animPlayer.animation_finished
		queue_free()
		get_tree().change_scene_to_file("res://menu.tscn")

	move_and_slide()
	

func movie_state():
	movmient()
	if Input.is_action_pressed("run"):
		run_spped = 2.5
	else:
		run_spped = 1
	if Input.is_action_pressed("block"):
		if velocity.x == 0:
			state = BLOCK
		else:
			state = SLIDE
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
func movmient():
	
	var direction = Input.get_axis("left", "right")

	if direction:
		velocity.x = direction * SPEED * run_spped
		if velocity.y == 0:
			if run_spped == 1:
				animPlayer.play("Walk")
			else:
				animPlayer.play("Run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.y == 0:
			animPlayer.play("idle")
	if direction == -1:
		anim.flip_h = true
	elif direction == 1:
		anim.flip_h = false

func block_state():
	velocity.x = 0
	animPlayer.play("Block")
	if Input.is_action_just_released("block"):
		state = MOVIE
func slide_state():
	animPlayer.play("Slide")
	await animPlayer.animation_finished
	state = MOVIE
func attack_state():
	velocity.x = 0
	animPlayer.play("Attack")
	await animPlayer.animation_finished
	state = MOVIE
