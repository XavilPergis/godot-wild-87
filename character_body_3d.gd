extends CharacterBody3D

const SPEED = 3.0
@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D

func _ready():
	animated_sprite_3d.pause()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_west", "move_east", "move_north", "move_south")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		animated_sprite_3d.play()
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
		# animation
	if direction.x > 0:
		animated_sprite_3d.flip_h = true
	elif direction.x < 0:
		animated_sprite_3d.flip_h = false
	
	if direction.x != 0:
		if direction.y < 0:
			animated_sprite_3d.play("NDWalk")
		elif direction.y == 0:
			animated_sprite_3d.play("HWalk")
		else:
			animated_sprite_3d.play("SDWalk")
	else:
		if direction.y < 0:
			animated_sprite_3d.play("NWalk")
		elif direction.y > 0:
			animated_sprite_3d.play("SWalk")
		else:
			animated_sprite_3d.pause()

	move_and_slide()
