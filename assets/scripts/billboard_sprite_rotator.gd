extends Node
class_name BillboardSpriteRotator

@export var sprite: AnimatedSprite3D
@export var initial_animation: String

var _animations = {}
var _current_animation: _Animation = null

const FOUR_SIDED_SUFFIXES: Array[String] = ["_N", "_E", "_S", "_W"]
const EIGHT_SIDED_SUFFIXES: Array[String] = ["_N", "_NE", "_E", "_SE", "_S", "_SW", "_W", "_NW"]

func _ready() -> void:
	#_current_animation = _Animation.new(sprite.sprite_frames, "walk", sides)
	for anim_name in sprite.sprite_frames.get_animation_names():
		if anim_name.ends_with("_N"):
			var anim_name_base = anim_name.substr(0, anim_name.length() - 2)
			if ((sprite.sprite_frames.has_animation(anim_name_base + "_E") or 
				sprite.sprite_frames.has_animation(anim_name_base + "_W")) and 
				sprite.sprite_frames.has_animation(anim_name_base + "_S")):
				if ((sprite.sprite_frames.has_animation(anim_name_base + "_NE") or 
					sprite.sprite_frames.has_animation(anim_name_base + "_NW")) and
					(sprite.sprite_frames.has_animation(anim_name_base + "_SE") or 
					sprite.sprite_frames.has_animation(anim_name_base + "_SW"))):
					# 8-sided animation
					_animations[StringName(anim_name_base)] = _Animation.new(sprite.sprite_frames, anim_name_base, 8)
				else:
					# 4-sided animation
					_animations[StringName(anim_name_base)] = _Animation.new(sprite.sprite_frames, anim_name_base, 4)
	
	set_animation(initial_animation)
	pass

func set_animation(p_name: StringName):
	if _animations.has(p_name):
		_current_animation = _animations[p_name]
	elif sprite.sprite_frames.has_animation(p_name):
		_current_animation = null
		sprite.animation = p_name
		sprite.flip_h = false
		sprite.stop()
		sprite.play()

func _update_sprite_angle():
	if _current_animation:
		var vec3_to_camera = sprite.global_position.direction_to(get_viewport().get_camera_3d().global_position)
		var vec2_to_camera = Vector2(vec3_to_camera.z, -vec3_to_camera.x)

		var angle = sprite.global_basis.get_euler().y + vec2_to_camera.angle()
		
		var sub_anim = _current_animation.get_sub_animation(angle)
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
				return
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
	_update_sprite_angle()
	pass
