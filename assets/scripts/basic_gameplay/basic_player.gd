class_name Player extends CharacterBody3D

@export var camera: MovableCamera
@export var camera_anchor: Node3D
@export var speed: float = 5.0
@export var crawling_speed: float = 2.5
@export var crawl_rotation_speed: float = 2.0
@export var lookaround_distance: float = 2.0
@export var lookaround_offset: float = 2.0

var is_crawling: bool = false
var is_looking_behind_wall: bool = false
var use_camera_angle: bool = false
var is_invisible_to_agents: bool = false

@onready var standing_allowed_cast: ShapeCast3D = $StandingAllowedCast
@onready var left_visibility: RayCast3D = $LeftVisibility
@onready var right_visibility: RayCast3D = $RightVisibility
@onready var look_around_wall_anchor: Node3D = $LookAroundWallAnchor
@onready var eyes: Node3D = $Eyes
@onready var sprite_rotator: BillboardSpriteRotator = $BillboardSprite/BillboardSpriteRotator


func set_crawling(crawling: bool) -> void:
	if is_crawling != crawling:
		is_crawling = crawling
		$StandingShape.set_deferred("disabled", crawling)
		$CrawlingShape.set_deferred("disabled", not crawling)
		$CrawlSprite.set_deferred("visible", crawling)
		$BillboardSprite.set_deferred("visible", not crawling)

const ANGLES: Array[float] = [
	0.0 * PI / 4, 1.0 * PI / 4, 2.0 * PI / 4, 3.0 * PI / 4,
	4.0 * PI / 4, 5.0 * PI / 4, 6.0 * PI / 4, 7.0 * PI / 4,
]

func find_closest_angle(angle: float) -> float:
	var closest = 0
	for i in ANGLES.size():
		var dist = abs(angle_difference(angle, ANGLES[i]))
		var closest_dist = abs(angle_difference(angle, ANGLES[closest]))
		if dist < closest_dist: closest = i
	return ANGLES[closest]

func _tick_wall_lookaround() -> void:
	var was_looking_behind_wall = is_looking_behind_wall
	is_looking_behind_wall = Input.is_action_pressed("wall_lookaround")
	
	var left = not left_visibility.is_colliding()
	var right = not right_visibility.is_colliding()
	var normal = Vector3.ZERO
	match [left, right]:
		[true, false]: normal = right_visibility.get_collision_normal()
		[false, true]: normal = left_visibility.get_collision_normal()
		
	is_looking_behind_wall = is_looking_behind_wall \
		and not normal.is_zero_approx() \
		and global_basis.z.dot(normal) > 0.8

	if not was_looking_behind_wall and is_looking_behind_wall:
		var anchor = look_around_wall_anchor
		if left != right:
			var xoffset = lookaround_offset
			if left and not right: xoffset = -xoffset
			anchor.position = Vector3.ZERO
			anchor.position.y = eyes.position.y
			anchor.position += lookaround_distance * (global_basis.inverse() * normal)
			anchor.look_at(eyes.global_position)
			anchor.position.x += xoffset
			camera.set_target(anchor, null, 0.5)
	elif was_looking_behind_wall and not is_looking_behind_wall:
		camera.set_target(camera_anchor, self, 0.5)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	var can_stand = not standing_allowed_cast.is_colliding()
	is_invisible_to_agents = not can_stand
	set_crawling(Input.is_action_pressed("crawl") or (is_crawling and not can_stand))
	var real_speed = crawling_speed if is_crawling else speed

	var input_dir = Input.get_vector("move_west", "move_east", "move_north", "move_south")
	var movement = Vector3(input_dir.x, 0, input_dir.y)
	movement = movement.rotated(Vector3.UP, GameState.instance.camera_angle)
	if not movement.is_zero_approx():
		look_at(global_position + movement)
		if is_crawling:
			$CrawlSprite.play("crawl")
		else:
			if sprite_rotator.animation != &"walk":
				sprite_rotator.play(&"walk")
		movement = movement
		velocity.x = movement.x * real_speed
		velocity.z = movement.z * real_speed
	else:
		if sprite_rotator.animation != &"idle":
			sprite_rotator.play(&"idle")
		if is_crawling:
			$CrawlSprite.pause()
		use_camera_angle = false  
		velocity.x = move_toward(velocity.x, 0, real_speed)
		velocity.z = move_toward(velocity.z, 0, real_speed)

	move_and_slide()
	_tick_wall_lookaround()

	# im not worrying about overlapping interactables rn. this code just
	# interacts will all interaction areas the player is touching
	# concurrently, which is probably not what we want.
	for intr in $InteractionArea.get_overlapping_areas():
		if intr is Interactable:
			intr.interacting = Input.is_action_pressed("interact")

func _ready() -> void:
	GameState.instance.game_lost.connect(_on_game_lost)
	GameState.instance.game_won.connect(_on_game_won)

func _on_health_component_took_damage(damage_amount: int) -> void:
	print(damage_amount, " damage!! ow!!")

func _on_health_component_died() -> void:
	print("died! bleh!")
	GameState.instance.game_lost.emit()

func _on_game_won() -> void:
	remove_child($HealthComponent)

func _on_game_lost() -> void:
	queue_free()
