class_name Interactable extends Area3D

signal interact_start()
signal interact_end()

@export var interact_amount: float = 1.0
@export var interact_fill_rate: float = 1.0
@export var interact_decay_rate: float = 0.2

var enabled: bool = true
var interacting: bool = false

enum State { Idle, Interacting, Finished }

var _state: State = State.Idle
var _interact_progress: float = 0.0

func _set_state(new_state: State) -> void:
	if _state != new_state:
		match new_state:
			State.Interacting: interact_start.emit()
			State.Finished: interact_end.emit()
	_state = new_state

func _physics_process(delta: float) -> void:
	var is_interacting = enabled and interacting
	match _state:
		State.Idle:
			_interact_progress = move_toward(_interact_progress, 0, interact_decay_rate * delta)
			if is_interacting:
				_set_state(State.Interacting)
		State.Interacting:
			_interact_progress = move_toward(_interact_progress, interact_amount, interact_fill_rate * delta)
			if not is_interacting:
				_set_state(State.Idle)
			if _interact_progress >= interact_amount:
				_set_state(State.Finished)
		State.Finished:
			pass
	
	# make the users of this class set `interacting` every physics tick to fill the progress bar.
	interacting = false
