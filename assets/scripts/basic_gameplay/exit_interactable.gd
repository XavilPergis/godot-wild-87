extends Interactable

@export var marker_height: float = 0.5
@onready var interaction_shape: CollisionShape3D = $InteractionShape
@onready var progress: ProgressBar = $SubViewport/ProgressBar
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var material: ShaderMaterial = mesh_instance.mesh.material

func _ready() -> void:
	enabled = false
	$MaterialScroller.material = mesh_instance.mesh.material

	var mesh = mesh_instance.mesh as CylinderMesh
	var shape = interaction_shape.shape as CylinderShape3D
	mesh_instance.transform = interaction_shape.transform
	mesh.height = marker_height
	mesh.top_radius = shape.radius
	mesh.bottom_radius = shape.radius
	material.set_shader_parameter("height", mesh.height)
	mesh_instance.position.y -= 0.5 * (shape.height - mesh.height)

func _process(_delta: float) -> void:
	progress.max_value = interact_amount
	progress.value = _interact_progress

func _physics_process(delta: float) -> void:
	enabled = GameState.instance.remaining_decay_interactables.is_empty()
	material.set_shader_parameter("disabled", not enabled)
	super(delta)

func _on_interact_end() -> void:
	GameState.instance.game_won.emit()
	print("you won!")

func _on_interact_start() -> void:
	pass
