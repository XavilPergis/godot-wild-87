extends CharacterBody3D

@export var camera: Camera3D
@export var speed: float = 5.0
@export var crawling_speed: float = 2.5
var is_crawling: bool = false

@onready var standing_allowed_cast: ShapeCast3D = $StandingAllowedCast

func set_crawling(crawling: bool) -> void:
	if is_crawling != crawling:
		is_crawling = crawling
		$StandingShape.set_deferred("disabled", crawling)
		$CrawlingShape.set_deferred("disabled", not crawling)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept"):
		global_basis = global_basis.rotated(Vector3.UP, deg_to_rad(360.0 / 8.0))

	var can_stand = not standing_allowed_cast.is_colliding()
	set_crawling(Input.is_action_pressed("crawl") or (is_crawling and not can_stand))
	var real_speed = crawling_speed if is_crawling else speed

	var input_dir = Input.get_vector("move_west", "move_east", "move_north", "move_south")
	var input_mag = input_dir.length()
	var looking_at_player = Basis.looking_at(global_position - $CameraAnchor.global_position)
	var angles = looking_at_player.get_euler()
	var direction = Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, angles.y)
	if not direction.is_zero_approx():
		direction = direction.normalized()
		direction *= input_mag
		velocity.x = direction.x * real_speed
		velocity.z = direction.z * real_speed
	else:
		velocity.x = move_toward(velocity.x, 0, real_speed)
		velocity.z = move_toward(velocity.z, 0, real_speed)

	move_and_slide()


func _on_health_component_took_damage(damage_amount: int) -> void:
	print(damage_amount, " damage!! ow!!")


func _on_health_component_died() -> void:
	print("died! bleh!")
	queue_free()
