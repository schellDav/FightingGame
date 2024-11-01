extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -300.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var is_attacking: bool = false  # Zustandsvariable für den Angriff

func _ready():
	# Signal für Animation beenden verbinden
	animated_sprite.connect("frame_changed", Callable(self, "_on_frame_changed"))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")

	# Change looking direction
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	# Handle attack if not already attacking
	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		animated_sprite.play("attack")

	# Play animations
	if is_on_floor():
		if direction == 0 and not is_attacking:
			animated_sprite.play("idle")
		elif direction != 0 and not is_attacking:
			animated_sprite.play("run")
	elif not is_attacking:
		animated_sprite.play("jump")

	# Update velocity
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _on_frame_changed():
	if animated_sprite.animation == "attack" and animated_sprite.frame == animated_sprite.sprite_frames.get_frame_count("attack") - 1:
		is_attacking = false
