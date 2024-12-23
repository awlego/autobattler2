class_name GameController
extends Node

signal game_state_changed

var game_state: GameState
var game_view: GameView
var card_controller: CardController

# Use these to set up the controller
func setup(state: GameState, view: GameView):
	game_state = state
	game_view = view
	
	# Create and setup card controller
	card_controller = CardController.new()
	card_controller.setup(game_state, game_view)

func start_combat():
	print("\nStarting combat phase...")
	
	# Get cards in the battle zones
	var player_cards = game_state.player_board
	var opponent_cards = game_state.opponent_board
	
	print("Combat setup - Player cards:", player_cards.size(), "Opponent cards:", opponent_cards.size())
	
	# Process combat for each position
	for i in range(max(player_cards.size(), opponent_cards.size())):
		var player_card = player_cards[i] if i < player_cards.size() else null
		var opponent_card = opponent_cards[i] if i < opponent_cards.size() else null
		
		if player_card and opponent_card:
			print("\nProcessing combat at position", i)
			print("Player card:", player_card.card_name, 
				  "(ATK:", player_card.attack, "HP:", player_card.health, ")",
				  "vs",
				  "Opponent card:", opponent_card.card_name,
				  "(ATK:", opponent_card.attack, "HP:", opponent_card.health, ")")
			
			# Apply damage simultaneously
			var player_damage = player_card.attack
			var opponent_damage = opponent_card.attack
			
			player_card.health -= opponent_damage
			opponent_card.health -= player_damage
			
			print("Combat results:",
				  "\n -", player_card.card_name, "took", opponent_damage, "damage, HP now:", player_card.health,
				  "\n -", opponent_card.card_name, "took", player_damage, "damage, HP now:", opponent_card.health)
			
			# Update the view after each combat
			game_view.update_display(game_state)
			# Optional: Add a small delay to see the health changes
			await get_tree().create_timer(0.5).timeout
	
	# Remove dead cards from state
	remove_dead_cards(player_cards)
	remove_dead_cards(opponent_cards)
	
	# Final update to remove dead cards from view
	game_view.update_display(game_state)
	print("\nCombat phase complete!")

func remove_dead_cards(cards: Array):
	var cards_to_remove = []
	for card in cards:
		if card.health <= 0:
			print("Card died:", card.card_name)
			cards_to_remove.append(card)
	
	# Remove cards after iteration
	for card in cards_to_remove:
		cards.erase(card)  # Remove directly from the array

# ... rest of the GameController code ...
