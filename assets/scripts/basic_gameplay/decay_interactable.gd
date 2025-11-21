extends Interactable

@onready var progress: ProgressBar = $SubViewport/ProgressBar

func _process(_delta: float) -> void:
	progress.max_value = interact_amount
	progress.value = _interact_progress

func _ready() -> void:
	GameState.instance.remaining_decay_interactables.push_back(self)

func _on_interact_end() -> void:
	var remaining = GameState.instance.remaining_decay_interactables
	var selfIndex = remaining.find(self)
	if selfIndex >= 0:
		remaining.remove_at(selfIndex)
		print("planted decay!")
	queue_free()


func _on_interact_start() -> void:
	print("interaction started")
