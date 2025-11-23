extends CharacterBody3D

@export var player: Player
@export var sprite_rotator: BillboardSpriteRotator
@export_group("Gameplay")
@export var movement_speed: float = 5.0
# TODO: this should probably be controlled by an animation
@export var scan_time: float = 4.0
## The input to this curve is distance to the player, the output is its field of view, in degrees.
## For example, an output of 90 would mean the agent can detect the player as far back as 45 degrees
## from it look direction to both its left and its right.
@export var fov_over_distance: Curve = preload("res://assets/curves/patrol_agent_detection_angle_curve.tres")
## How much the detection angle should be multiplied by while the agent is walking between nodes.
@export var movement_detection_angle_factor: float = 0.5
@export var pursuit_timeout: float = 4.0
@export var attack_strength: int = 1
@export var attack_timeout: float = 1.5
## The amount of time after losing direct line of sight to the player, after which the agent will
## stop updating its target position. Higher values make the agents feel smarter.
@export var player_tracking_cutoff: float = 0.5

var patrol_route: PatrolRoute
@onready var eyes: Node3D = $Eyes
@onready var nav_agent: NavigationAgent3D = $NavigationAgent

@export var move_sound_start_point: float = 2.386
@export var move_sound_loop_start: float = 5.488
@export var move_sound_end_point: float = 58.219

@export var alert_sounds: Array[AudioStream]
@export var shrug_sounds: Array[AudioStream]
@export var zap_sounds: Array[AudioStream]

enum State { IDLE, MOVE_TO_TARGET, CHASE, SCAN, }

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var state: State = State.IDLE
# for `State.SCAN`
var scan_time_remaining: float
# for `State.CHASE`
var pursuit_timeout_remaining: float
var attack_timeout_remaining: float
## the amount of time that the agent has lost track of the player for
var cant_see_player_time: float

# updated by some signal handlers
var attack_targets: Array[Node3D] = []

func _ready() -> void:
	sprite_rotator.play("walk")
	for node in get_children():
		if node is PatrolRoute:
			patrol_route = node
			patrol_route.navigation_agent = nav_agent
	if not patrol_route:
		push_warning("patrol agent '", name, "' does not have a child PatrolRoute")

func play_alert_sound():
	randomize()
	$sfx_voice.stream = alert_sounds[randi_range(0, alert_sounds.size()-1)]
	$sfx_voice.play()
	
func play_shrug_sound():
	randomize()
	$sfx_voice.stream = shrug_sounds[randi_range(0, alert_sounds.size()-1)]
	$sfx_voice.play()
	
func play_zap_sound():
	randomize()
	$sfx_zap.stream = zap_sounds[randi_range(0, alert_sounds.size()-1)]
	$sfx_zap.play()
	
func _on_bark_timer_timeout() -> void:
	if state == State.CHASE:
		play_alert_sound()
	else:
		$BarkTimer.stop()

func set_state(new_state: State) -> void:
	if state == State.CHASE and new_state != State.CHASE:
		play_shrug_sound()
	state = new_state
	match new_state:
		State.SCAN:
			scan_time_remaining = scan_time
		State.CHASE:
			play_alert_sound()
			$BarkTimer.start()

func look_at_horiz(target: Vector3) -> void:
	target = Vector3(target.x, global_position.y, target.z)
	if not is_equal_approx(target.x, global_position.x) \
		or not is_equal_approx(target.z, global_position.z):
		look_at(target, Vector3.UP)

func can_see(target: Vector3) -> bool:
	if player.is_invisible_to_agents: return false
	#target = Vector3(target.x, eyes.global_position.y, target.z)
	var to_target = target - eyes.global_position
	var facing = global_basis * Vector3.FORWARD
	var facing_alignment = to_target.normalized().dot(facing)
	if facing_alignment < 0.0:
		return false
	var query = PhysicsRayQueryParameters3D.new()
	query.from = eyes.global_position
	query.to = target
	query.collision_mask = 1 << 1
	var res = get_world_3d().direct_space_state.intersect_ray(query)
	return res.is_empty()

func attack(target: Node3D):
	var health = target.get_meta(Components.HEALTH) as HealthComponent
	health.damage(attack_strength)
	play_zap_sound()
	sprite_rotator.play("angry")
	$AngryFaceTimer.start()
	attack_timeout_remaining = attack_timeout

func tick_pursuit(delta: float) -> void:
	if not is_instance_valid(player):
		patrol_route.target_nearest_point()
		set_state(State.MOVE_TO_TARGET)
		return

	var can_see_player = can_see(player.global_position)
	# we don't want to lose sight of the player, even if we're in the attack timeout.
	if can_see_player:
		look_at_horiz(player.global_position)
	attack_timeout_remaining = move_toward(attack_timeout_remaining, 0, delta)
	# if there's anything in `attack_targets`, that means its in melee range
	# and we should attempt to attack it.
	if len(attack_targets) > 0:
		if attack_timeout_remaining <= 0:
			var target = attack_targets[rng.randi_range(0, len(attack_targets) - 1)]
			look_at_horiz(target.global_position)
			if target.has_meta(Components.HEALTH):
				if can_see_player:
					attack(target)
	# otherwise, we should try to close the distance between the agent and the
	# player. we wait until the attack timeout timer is done, so the agent will
	# freeze for a little bit before resuming the chase.
	elif attack_timeout_remaining <= 0:
		# we want the agent to pathfind to the player's last known location.
		# the known location should be updated constantly when the agent can directly see us.
		cant_see_player_time = cant_see_player_time + delta if not can_see_player else 0.0
		if cant_see_player_time < player_tracking_cutoff:
			nav_agent.target_position = player.global_position + 0.25 * Vector3.UP

		# shrimply move towards the target
		if not nav_agent.is_navigation_finished():
			var target_pos = nav_agent.get_next_path_position()
			velocity = (target_pos - global_position).normalized() * movement_speed
			if not can_see_player:
				look_at_horiz(target_pos)
			move_and_slide()

		# lose interest in chasing the player if the agent cant see them for a
		# long enough period of time.
		if nav_agent.is_navigation_finished() and not can_see_player:
			pursuit_timeout_remaining = move_toward(pursuit_timeout_remaining, 0, delta)
			if pursuit_timeout_remaining <= 0:
				patrol_route.target_nearest_point()
				set_state(State.MOVE_TO_TARGET)
		else:
			pursuit_timeout_remaining = pursuit_timeout

func _process(_delta: float) -> void:
	if state == State.MOVE_TO_TARGET || state == State.CHASE:
		if $sfx_move.has_stream_playback():
			if $sfx_move.get_playback_position() > move_sound_end_point:
				$sfx_move.seek(move_sound_loop_start)
		else:
			$sfx_move.play(move_sound_start_point)
	elif $sfx_move.has_stream_playback():
		if $sfx_move.get_playback_position() < move_sound_end_point:
				$sfx_move.seek(move_sound_end_point)

func _physics_process(delta: float) -> void:
	if not patrol_route: return
	if state != State.CHASE and is_instance_valid(player):
		var to_player = player.global_position - global_position
		var facing = global_basis * Vector3.FORWARD
		var facing_alignment = facing.dot(to_player.normalized()) if not to_player.is_zero_approx() else 1.0
		var facing_angle = acos(facing_alignment)
		var player_distance = to_player.length()

		# `facing_angle` tells us the angle from the forward dir, but `fov_over_distance`
		# is specified in terms of fov, so we bisect the fov triangle to get it
		# in terms of the angle from forward too.
		var detection_angle = 0.5 * deg_to_rad(fov_over_distance.sample_baked(player_distance))
		# apply a FOV penalty when moving, as if you're looking where you're
		# going and not scanning so much.
		if state == State.MOVE_TO_TARGET:
			detection_angle *= movement_detection_angle_factor
		if facing_angle <= detection_angle \
			and player_distance < fov_over_distance.max_domain \
			and can_see(player.global_position):
			set_state(State.CHASE)
	
	match state:
		State.IDLE:
			patrol_route.target_nearest_point()
			set_state(State.MOVE_TO_TARGET)
		State.CHASE:
			tick_pursuit(delta)
		State.MOVE_TO_TARGET:
			var target_pos = patrol_route.next_point_position()
			velocity = (target_pos - global_position).normalized() * movement_speed
			if not global_position.is_equal_approx(target_pos):
				look_at_horiz(target_pos)
			move_and_slide()
			if nav_agent.is_target_reached():
				if patrol_route.current_point().should_scan:
					var point = patrol_route.current_point()
					global_basis = point.global_basis
					set_state(State.SCAN)
				else:
					patrol_route.target_next_point()
		State.SCAN:
			# TODO: scan animation
			scan_time_remaining = move_toward(scan_time_remaining, 0, delta)
			if scan_time_remaining <= 0:
				patrol_route.target_next_point()
				set_state(State.MOVE_TO_TARGET)

func _on_physical_hurtbox_body_entered(body: Node3D) -> void:
	if body not in attack_targets:
		attack_targets.push_back(body)
func _on_physical_hurtbox_body_exited(body: Node3D) -> void:
	attack_targets.remove_at(attack_targets.find(body))

func _on_angry_face_timer_timeout() -> void:
	sprite_rotator.play("walk")
	pass # Replace with function body.
