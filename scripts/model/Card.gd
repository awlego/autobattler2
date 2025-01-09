class_name Card

var card_name: String
var attack: int
var health: int
var cost: int
var effects: Array[CardEffect] = []  # We'll create CardEffect class later

func _init(name: String, atk: int, hp: int, card_cost: int):
	card_name = name
	attack = atk
	health = hp
	cost = card_cost

func take_damage(amount: int) -> bool:
	health -= amount
	return health <= 0  # Returns true if card is destroyed

func can_attack() -> bool:
	return attack > 0

func attack_target(target: Card) -> void:
	if target and can_attack():
		target.take_damage(attack)

func clone() -> Card:
	var new_card = Card.new(card_name, attack, health, cost)
	new_card.effects = effects.duplicate()
	return new_card

func _to_string() -> String:
	return "Card: %s (%d/%d) Cost: %d" % [card_name, attack, health, cost]

