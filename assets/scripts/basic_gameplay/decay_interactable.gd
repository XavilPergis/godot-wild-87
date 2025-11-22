extends Interactable

@onready var progress: ProgressBar = $SubViewport/ProgressBar
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var interaction_shape: CollisionShape3D = $InteractionShape
@onready var progress_bar_sprite: Sprite3D = $ProgressBarSprite

@export var marker_height: float = 0.5

func _process(_delta: float) -> void:
	progress_bar_sprite.visible = _interact_progress > 0.0
	progress.max_value = interact_amount
	progress.value = _interact_progress

func _ready() -> void:
	GameState.instance.remaining_decay_interactables.push_back(self)

	var mesh = mesh_instance.mesh as CylinderMesh
	var shape = interaction_shape.shape as CylinderShape3D
	mesh_instance.transform = interaction_shape.transform
	mesh.height = marker_height
	mesh.top_radius = shape.radius
	mesh.bottom_radius = shape.radius
	mesh.material.set_shader_parameter("height", mesh.height)
	mesh_instance.position.y -= 0.5 * (shape.height - mesh.height)

func _on_interact_end() -> void:
	var remaining = GameState.instance.remaining_decay_interactables
	var selfIndex = remaining.find(self)
	if selfIndex >= 0:
		remaining.remove_at(selfIndex)
		print("planted decay!")
	queue_free()

func _on_interact_start() -> void:
	print("interaction started")
