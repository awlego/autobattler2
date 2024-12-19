# CombatVisualManager.gd
extends Node2D

const CardVisual = preload("res://scripts/CardVisual.gd")
const CARD_SPACING = 150
const PLAYER_Y = 400
const OPPONENT_Y = 200
const START_X = 100
const SLOT_SIZE = Vector2(100, 150)
const CombatZoneManager = preload("res://scripts/CombatZoneManager.gd")

var combat_manager: CombatManager
var card_visuals: Dictionary = {}
var zone_manager: CombatZoneManager

func _ready():
	combat_manager = CombatManager.new()
	
	# Setup zones
	zone_manager = CombatZoneManager.new()
	add_child(zone_manager)
	zone_manager.setup_zones(START_X, PLAYER_Y, OPPONENT_Y)
	
	# Add a button to start combat
	var combat_button = Button.new()
	combat_button.text = "Execute Combat Round"
	combat_button.position = Vector2(400, 300)
	combat_button.pressed.connect(execute_combat_round)
	add_child(combat_button)
	
	setup_test_battle()

func setup_test_battle():
	# Create some test cards
	var knight = CombatCard.new("Knight", 3, 4, 3)
	var goblin = CombatCard.new("Goblin", 2, 2, 1)
	var dragon = CombatCard.new("Dragon", 5, 5, 5)
	
	# Place cards on the board using the new helper method
	place_and_visualize_card(knight, 0, true)   # Player's knight
	place_and_visualize_card(goblin, 1, false)  # Opponent's goblin
	place_and_visualize_card(dragon, 2, false)  # Opponent's dragon

func place_and_visualize_card(card: CombatCard, position: int, is_player: bool):
	# Place card in combat manager
	combat_manager.place_card(card, position, is_player)
	# Create matching visual representation
	create_card_visual(card, position, is_player)

func create_card_visual(card: CombatCard, card_position: int, is_player: bool):
	var card_visual = CardVisual.new()
	add_child(card_visual)
	card_visual.setup_card(card, is_player)
	
	# Get the appropriate slot position
	var slots = zone_manager.player_slots if is_player else zone_manager.opponent_slots
	if card_position < slots.size():
		var slot = slots[card_position]
		# Center the card in the slot
		card_visual.position = slot.position
	
	# Store reference to card visual
	card_visuals[card] = card_visual

func execute_combat_round():
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

