extends Component
class_name HealthComponent

@export var max_health: int = 10
@export var damage_cooldown_seconds: float = 0.5

var health
var _accumulated_damage = 0
var _damage_cooldown_remaining = 0

signal died()
signal took_damage(damage_amount: int)

func _init():
	super(Components.HEALTH)

func _ready() -> void:
	health = max_health
	
func _physics_process(delta: float) -> void:
	_damage_cooldown_remaining = move_toward(_damage_cooldown_remaining, 0, delta)
	if _damage_cooldown_remaining <= 0:
		_accumulated_damage = 0

func is_dead() -> bool:
	return health <= 0

func damage(damage_amount: int) -> void:
	var prev_health = health
	var damage_delta = max(0, damage_amount - _accumulated_damage)
	_accumulated_damage += damage_delta
	health -= damage_delta
	if damage_delta > 0:
		_damage_cooldown_remaining = damage_cooldown_seconds
		if prev_health > 0:
			took_damage.emit(damage_delta)
		if prev_health > 0 and health <= 0:
			died.emit()
