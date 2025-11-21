extends Interactable

func _ready() -> void:
	enabled = false

@onready var progress: ProgressBar = $SubViewport/ProgressBar

func _process(_delta: float) -> void:
	progress.max_value = interact_amount
	progress.value = _interact_progress

func _physics_process(delta: float) -> void:
	enabled = GameState.instance.remaining_decay_interactables.is_empty()
	super(delta)

func _on_interact_end() -> void:
	GameState.instance.game_won.emit()
	print("you won!")

func _on_interact_start() -> void:
	pass
