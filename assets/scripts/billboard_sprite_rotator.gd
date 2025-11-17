extends Node3D
class_name BillboardSpriteRotator

@export var sprite: AnimatedSprite3D
@export var sides: int

var walk_animation: _Animation

const FOUR_SIDED_SUFFIXES: Array[String] = ["_N", "_E", "_S", "_W"]
const EIGHT_SIDED_SUFFIXES: Array[String] = ["_N", "_NE", "_E", "_SE", "_S", "_SW", "_W", "_NW"]

func _ready() -> void:
	walk_animation = _Animation.new(sprite.sprite_frames, "walk", sides)
	pass

func update_sprite_angle():
	var vec3_to_camera = global_position.direction_to(get_viewport().get_camera_3d().global_position)
	var vec2_to_camera = Vector2(vec3_to_camera.z, -vec3_to_camera.x)

	var angle = self.global_basis.get_euler().y + vec2_to_camera.angle()
	
	var sub_anim = walk_animation.get_sub_animation(angle)
	sprite.animation = sub_anim.animation
	sprite.flip_h = sub_anim.flip_h

class _Animation:
	# North, East, South, West
	var anims: Array[_SubAnimation] = []
	
	func _init(p_frames: SpriteFrames, p_base_name: String, p_num_sides: int):
		var suffixes: Array[String]
		match p_num_sides:
			1:
				anims = [_SubAnimation.new(p_base_name, false)]
			4:
				suffixes = FOUR_SIDED_SUFFIXES
			8:
				suffixes = EIGHT_SIDED_SUFFIXES
			_:
				assert(false, "Must have one, four, or eight sides!!")
		
		anims.resize(p_num_sides)
		
		for i in p_num_sides:
			var name = StringName(p_base_name + suffixes[i])
			if p_frames.has_animation(name):
				anims[i] = _SubAnimation.new(name, false)
			elif suffixes[i].contains("E"):
				# try flipping it to W
				name = StringName(p_base_name + suffixes[i].replace("E", "W"))
				if p_frames.has_animation(name):
					anims[i] = _SubAnimation.new(name, true)
				else:
					assert(false, "Could not fill sub-animations!!")
			elif suffixes[i].contains("W"):
				# try flipping it to E
				name = StringName(p_base_name + suffixes[i].replace("W", "E"))
				if p_frames.has_animation(name):
					anims[i] = _SubAnimation.new(name, true)
				else:
					assert(false, "Could not fill sub-animations!!")
			else:
				assert(false, "Could not fill sub-animations!!")

	func get_sub_animation(angle: float) -> _SubAnimation:
		if anims.size() == 1:
			return anims[0]
		else:
			var offset_angle = wrapf(PI + PI/anims.size() - angle, 0, 2*PI)
			return anims[floor(offset_angle * anims.size() / (2*PI))]

class _SubAnimation:
	func _init(p_animation: StringName, p_flip_h: bool):
		animation = p_animation
		flip_h = p_flip_h
		
	func flip() -> _SubAnimation:
		return _SubAnimation.new(animation, not flip_h)
	
	var animation: StringName
	var flip_h: bool

func _process(_delta: float) -> void:
	update_sprite_angle()
	pass
