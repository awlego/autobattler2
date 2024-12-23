# CombatVisualManager.gd
extends Node2D

const CardScript = preload("res://scripts/Card.gd")

const CardVisualScript = preload("res://scripts/CardVisual.gd")
const CARD_SPACING = 150
const PLAYER_Y = 400
const OPPONENT_Y = 200
const START_X = 100
const SLOT_SIZE = Vector2(100, 150)
const CombatZoneManager = preload("res://scripts/CombatZoneManager.gd")

var combat_manager: CombatManager
var card_visuals: Dictionary = {}
var zone_manager: CombatZoneManager
var in_combat: bool = false
var player_zone: CardContainer
var opponent_zone: CardContainer

func _ready():
	combat_manager = CombatManager.new()
	
	# Setup zones
	zone_manager = CombatZoneManager.new()
	add_child(zone_manager)
	zone_manager.position = Vector2(START_X, 0)
	zone_manager.setup_zones(START_X, PLAYER_Y, OPPONENT_Y)
	
	# Add a button to start combat
	var combat_button = Button.new()
	combat_button.text = "Execute Combat Round"
	combat_button.position = Vector2(900, 900)
	combat_button.pressed.connect(execute_combat_round)
	add_child(combat_button)
	
	setup_combat_zones()

func setup_combat_zones():
	# Create player zone
	player_zone = CardContainer.new()
	player_zone.container_name = "PlayerCombatZone"
	player_zone.position = Vector2(200, 400)
	player_zone.custom_minimum_size = Vector2(800, 200)
	add_child(player_zone)
	
	# Create opponent zone
	opponent_zone = CardContainer.new()
	opponent_zone.container_name = "OpponentCombatZone"
	opponent_zone.position = Vector2(200, 200)
	opponent_zone.custom_minimum_size = Vector2(800, 200)
	opponent_zone.accepts_drops = false
	add_child(opponent_zone)

func _on_card_drag_started(_card: CardVisual):
	if in_combat:
		return
	zone_manager.highlight_valid_zones(true)

func _on_card_drag_ended(card: CardVisual, drop_position: Vector2):
	if in_combat:
		return
		
	zone_manager.highlight_valid_zones(false)
	zone_manager.clear_drop_preview()
	
	var slot_idx = zone_manager.get_slot_at_position(drop_position)
	if slot_idx != -1:
		handle_card_drop(card, slot_idx)

func handle_card_drop(card: CardVisual, new_slot: int):
	var old_slot = combat_manager.get_card_position(card.card_data)
	
	# Check if there's a card in the target slot
	var existing_card = combat_manager.get_card_at_position(new_slot, true)
	
	if existing_card:
		# Swap cards
		var existing_visual = card_visuals[existing_card]
		combat_manager.swap_cards(old_slot, new_slot)
		
		# Animate both cards
		card.move_to_position(zone_manager.player_slots[new_slot].position)
		existing_visual.move_to_position(zone_manager.player_slots[old_slot].position)
	else:
		# Simply move the card
		combat_manager.move_card(old_slot, new_slot)
		card.move_to_position(zone_manager.player_slots[new_slot].position)

func execute_combat_round():
	in_combat = true
	# Execute combat in the combat manager
	combat_manager.execute_combat_round()
	
	# Update all card visuals
	for card in card_visuals.keys():
		if card.health <= 0:
			# Play death animation and remove the card visual
			card_visuals[card].play_death_animation()
			# Wait for animation to complete before removing
			await card_visuals[card].anim_player.animation_finished
			card_visuals[card].queue_free()
			card_visuals.erase(card)
		else:
			# Update the card's display
			card_visuals[card].update_display()
	in_combat = false

func setup_test_cards():
	var hand_container = CardContainer.new()
	hand_container.container_name = "TestHand"
	hand_container.position = Vector2(150, 200)
	add_child(hand_container)
	
	# Create some sample cards with different stats
	var test_cards = [
		["Knight", 3, 4, 3],
		["Dragon", 5, 5, 5],
		["Goblin", 2, 2, 1]
	]
	
	for card_data in test_cards:
		var card = CardScript.new(card_data[0], card_data[1], card_data[2], card_data[3])
		var card_visual = CardVisualScript.new()
		card_visual.setup_card(card)
		hand_container.add_card(card_visual)

