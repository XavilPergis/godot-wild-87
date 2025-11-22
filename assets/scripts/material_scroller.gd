extends Node

static var _has_main_instance: bool = false

@export var material: ShaderMaterial
@export var scroll_speed: float = 1.0

var _is_main_instance: bool = false
var _scroll_offset: float = 0.0

func _ready() -> void:
	_is_main_instance = not _has_main_instance
	_has_main_instance = true

func _process(delta: float) -> void:
	if not _is_main_instance: return
	_scroll_offset += scroll_speed * delta
	if _scroll_offset > material.get_shader_parameter("frequency"):
		_scroll_offset = 0.0
	material.set_shader_parameter("scroll_offset", _scroll_offset)
