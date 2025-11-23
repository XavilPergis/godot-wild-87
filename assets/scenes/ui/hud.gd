extends Control

@onready var health_bar: ProgressBar = %HealthBar
@onready var decay_bar: ProgressBar = %DecayBar

func _process(_delta: float) -> void:
	var state = GameState.instance
	health_bar.value = 0
	if is_instance_valid(state.player):
		if state.player.has_meta(Components.HEALTH):
			var health = state.player.get_meta(Components.HEALTH) as HealthComponent
			health_bar.indeterminate = false
			health_bar.max_value = health.max_health
			health_bar.value = health.health
		else:
			health_bar.indeterminate = true

	decay_bar.max_value = len(state.decay_interactables)
	decay_bar.value = len(state.decay_interactables) - len(state.remaining_decay_interactables)
