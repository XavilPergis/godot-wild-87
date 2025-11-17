extends CharacterBody3D

@onready var patrol_route: PatrolRoute = $PatrolRoute

func _ready() -> void:
	pass 

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		patrol_route.target_next_point()

func _physics_process(_delta: float) -> void:
	var direction = patrol_route.direction_to_next_point(global_position)
	
	velocity = direction * 5.0
	move_and_slide()
