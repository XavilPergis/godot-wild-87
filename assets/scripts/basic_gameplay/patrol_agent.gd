extends CharacterBody3D

@export var player: Node3D
@export_category("Gameplay")
@export var movement_speed: float = 5.0
# TODO: this should probably be controlled by an animation
@export var scan_time: float = 4.0
## The input to this curve is distance to the player, the output is its field of view, in degrees.
## For example, an output of 90 would mean the agent can detect the player as far back as 45 degrees
## from it look direction to both its left and its right.
@export var fov_over_distance: Curve = preload("res://assets/curves/patrol_agent_detection_angle_curve.tres")
## How much the detection angle should be multiplied by while the agent is walking between nodes.
@export var movement_detection_angle_factor: float = 0.5

@onready var patrol_route: PatrolRoute = $PatrolRoute
@onready var raycast: RayCast3D = $RayCast
@onready var route_agent: NavigationAgent3D = $RouteAgent


enum State { IDLE, MOVE_TO_TARGET, PURSUE, SCAN, }

var state: State = State.IDLE
# for `State.SCAN`
var scan_time_remaining: float

func _ready() -> void:
	patrol_route.target_nearest_point()
	patrol_route.reached_target.connect(_on_reached_target)

func set_state(new_state: State) -> void:
	state = new_state
	match new_state:
		State.SCAN:
			scan_time_remaining = scan_time

func _physics_process(delta: float) -> void:
	var to_player = player.global_position - global_position
	var facing = global_basis * Vector3.FORWARD
	var facing_alignment = facing.dot(to_player.normalized()) if not to_player.is_zero_approx() else 1.0
	var facing_angle = acos(facing_alignment)
	var player_distance = to_player.length()
	
	var detection_angle = 0.5 * deg_to_rad(fov_over_distance.sample_baked(player_distance))
	if state == State.MOVE_TO_TARGET:
		detection_angle *= movement_detection_angle_factor
	if facing_angle <= detection_angle and player_distance < 20.0:
		raycast.target_position = raycast.to_local(player.global_position)
		raycast.collision_mask = (1 << 1)
		if not raycast.is_colliding():
			set_state(State.PURSUE)
	
	match state:
		State.IDLE:
			set_state(State.MOVE_TO_TARGET)
		State.PURSUE:
			# TODO: alert animation
			var target_pos = route_agent.get_next_path_position()
			velocity = (target_pos - global_position).normalized() * movement_speed
			look_at(target_pos, Vector3.UP)
			move_and_slide()
			route_agent.target_position = player.global_position
		State.MOVE_TO_TARGET:
			var target_pos = patrol_route.next_point_position()
			velocity = (target_pos - global_position).normalized() * movement_speed
			if not global_position.is_equal_approx(target_pos):
				look_at(target_pos, Vector3.UP)
			move_and_slide()
		State.SCAN:
			# TODO: scan animation
			scan_time_remaining = move_toward(scan_time_remaining, 0, delta)
			if scan_time_remaining <= 0:
				patrol_route.target_next_point()
				set_state(State.MOVE_TO_TARGET)

func _on_reached_target(_target: PatrolPoint) -> void:
	set_state(State.SCAN)
	
