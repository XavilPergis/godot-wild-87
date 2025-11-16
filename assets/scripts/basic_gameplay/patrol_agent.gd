extends CharacterBody3D

@export var movement_speed: float = 5.0
@export var patrol_route: PatrolRoute
@export var scan_time: float = 4.0
@export var player: Node3D

@onready var raycast: RayCast3D = $RayCast
@onready var route_agent: NavigationAgent3D = $RouteAgent

var state: State = State.IDLE

# for `State.SCAN`
var scan_time_remaining: float

enum State {
	IDLE,
	MOVE_TO_TARGET,
	PURSUE,
	SCAN,
}

func _ready() -> void:
	patrol_route.target_nearest_point()
	patrol_route.reached_target.connect(_on_reached_target)

#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("ui_accept"):
		#patrol_route.target_next_point()

func set_state(new_state: State) -> void:
	state = new_state
	match new_state:
		State.SCAN:
			scan_time_remaining = scan_time

func _physics_process(delta: float) -> void:
	var to_player = player.global_position - global_position
	var facing = global_basis * Vector3.FORWARD
	var facing_alignment = facing.dot(to_player.normalized()) if not to_player.is_zero_approx() else 1.0
	var player_distance = to_player.length()
	# could usse a Curve here?
	var detection_alignment = remap(player_distance, 10, 20, 0.5, 0.9)
	if facing_alignment >= detection_alignment and player_distance < 20.0:
		raycast.target_position = raycast.to_local(player.global_position)
		raycast.collision_mask = (1 << 1)
		if not raycast.is_colliding():
			set_state(State.PURSUE)
	
	match state:
		State.PURSUE:
			var target_pos = route_agent.get_next_path_position()
			velocity = (target_pos - global_position).normalized() * movement_speed
			look_at(target_pos, Vector3.UP)
			move_and_slide()
			route_agent.target_position = player.global_position
		State.IDLE:
			set_state(State.MOVE_TO_TARGET)
		State.MOVE_TO_TARGET:
			var target_pos = patrol_route.next_point_position()
			velocity = (target_pos - global_position).normalized() * movement_speed
			if not global_position.is_equal_approx(target_pos):
				look_at(target_pos, Vector3.UP)
			move_and_slide()
		State.SCAN:
			scan_time_remaining = move_toward(scan_time_remaining, 0, delta)
			if scan_time_remaining <= 0:
				patrol_route.target_next_point()
				set_state(State.MOVE_TO_TARGET)

func _on_reached_target(_target: PatrolPoint) -> void:
	set_state(State.SCAN)
	
