class_name CardEffect

enum EffectType {
	ON_PLAY,
	ON_DEATH,
	ON_DAMAGE,
	ON_ATTACK
}

var effect_type: EffectType
var effect_value: int

func _init(type: EffectType, value: int = 0):
	effect_type = type
	effect_value = value

func trigger(card: Card, target: Card = null) -> void:
	# Will implement specific effects later
	pass 
