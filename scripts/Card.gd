# Card.gd
extends Node2D

class_name CombatCard

var card_name: String
var attack: int
var health: int
var cost: int
var position_in_combat: int  # Position from 0-6 in combat line
var effects: Array = []  # Store special effects

func _init(card_name_param: String, atk: int, hp: int, card_cost: int):
    card_name = card_name_param
    attack = atk
    health = hp
    cost = card_cost

func take_damage(amount: int):
    health -= amount
    return health <= 0  # Returns true if card is destroyed

func attack_target(target: CombatCard):
    if target:
        target.take_damage(attack)

func _to_string() -> String:
    return "CombatCard: %s (%d/%d)" % [card_name, attack, health]
