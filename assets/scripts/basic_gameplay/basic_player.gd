extends CharacterBody3D


@export var camera: Camera3D
@export var speed: float = 5.0

const JUMP_VELOCITY = 4.5


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept"):
		global_basis = global_basis.rotated(Vector3.UP, deg_to_rad(360.0 / 8.0))

	var input_dir = Input.get_vector("move_west", "move_east", "move_north", "move_south")
	var input_mag = input_dir.length()
	var looking_at_player = Basis.looking_at(global_position - $CameraAnchor.global_position)
	var angles = looking_at_player.get_euler()
	var direction = Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, angles.y)
	if not direction.is_zero_approx():
		direction = direction.normalized()
		direction *= input_mag
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()


func _on_health_component_took_damage(damage_amount: int) -> void:
	print(damage_amount, " damage!! ow!!")


func _on_health_component_died() -> void:
	print("died! bleh!")
	queue_free()
