class_name GameController

signal turn_started(player_turn: bool)
signal phase_changed(phase: String)

var game_state: GameState
var game_view: GameView
var card_controller: CardController
var combat_controller: CombatController

func _init(state: GameState, view: GameView):
	game_state = state
	game_view = view
	card_controller = CardController.new(state)
	combat_controller = CombatController.new(state)
	
	# Wait for the view to be ready before connecting signals
	if view.is_inside_tree():
		_connect_signals()
	else:
		# Connect when the view is ready
		view.ready.connect(_connect_signals, CONNECT_ONE_SHOT)

func _connect_signals():
	# Connect view signals
	game_view.card_drag_started.connect(_on_card_drag_started)
	game_view.card_dropped.connect(_on_card_dropped)
	
	# Connect model signals
	game_state.state_changed.connect(_on_game_state_changed)
	
	# Connect card controller signals
	card_controller.card_played.connect(_on_card_played)
	card_controller.card_moved.connect(_on_card_moved)
	card_controller.cards_swapped.connect(_on_cards_swapped)
	
	# Connect combat controller signals
	combat_controller.combat_round_started.connect(_on_combat_started)
	combat_controller.combat_round_ended.connect(_on_combat_ended)
	combat_controller.card_attacked.connect(_on_card_attacked)
	combat_controller.card_died.connect(_on_card_died)

# Game flow methods
func start_game():
	game_state.current_phase = "setup"
	setup_test_cards()
	phase_changed.emit("setup")
	
	# Start first turn
	game_state.current_phase = "main"
	phase_changed.emit("main")

func start_combat():
	print("Starting combat phase...")
	
	# Get cards in the battle zones
	var player_cards = game_state.player_board
	var opponent_cards = game_state.opponent_board
	
	print("Player cards:", player_cards.size(), "Opponent cards:", opponent_cards.size())
	
	# Process combat for each position
	for i in range(max(player_cards.size(), opponent_cards.size())):
		var player_card = player_cards[i] if i < player_cards.size() else null
		var opponent_card = opponent_cards[i] if i < opponent_cards.size() else null
		
		if player_card and opponent_card:
			print("Processing combat at position", i)
			print("Player card:", player_card.card_name, "vs Opponent card:", opponent_card.card_name)
			
			# Apply damage
			opponent_card.health -= player_card.attack
			player_card.health -= opponent_card.attack
			
			print("After combat - Player card health:", player_card.health, 
				  "Opponent card health:", opponent_card.health)
	
	# Remove dead cards
	remove_dead_cards(player_cards)
	remove_dead_cards(opponent_cards)
	
	# Update the view
	emit_signal("game_state_changed")

func remove_dead_cards(cards: Array):
	var cards_to_remove = []
	for card in cards:
		if card.health <= 0:
			print("Card died:", card.card_name)
			cards_to_remove.append(card)
	
	# Remove cards after iteration
	for card in cards_to_remove:
		game_state.remove_card(card)

# View signal handlers
func _on_card_drag_started(card: Card, from_zone: String):
	if game_state.current_phase != "main":
		return
	# Highlight valid drop zones through view
	game_view.highlight_valid_zones(card, from_zone)

func _on_card_dropped(card: Card, from_zone: String, position: int):
	if game_state.current_phase != "main":
		return
		
	game_view.clear_highlights()
	
	if from_zone == "hand" and card_controller.play_card_from_hand(card, position):
		game_view.update_display(game_state)
	elif from_zone == "board" and card_controller.move_card(card.get_position(), position):
		game_view.update_display(game_state)

# Model signal handlers
func _on_game_state_changed():
	game_view.update_display(game_state)

# Card controller signal handlers
func _on_card_played(card: Card, position: int):
	game_view.update_display(game_state)

func _on_card_moved(card: Card, from_pos: int, to_pos: int):
	game_view.update_display(game_state)

func _on_cards_swapped(card1: Card, pos1: int, card2: Card, pos2: int):
	game_view.update_display(game_state)

# Combat controller signal handlers
func _on_combat_started():
	game_view.disable_interactions()

func _on_combat_ended():
	game_state.current_phase = "main"
	phase_changed.emit("main")
	game_view.update_display(game_state)
	game_view.enable_interactions()

func _on_card_attacked(attacker: Card, defender: Card):
	game_view.play_attack_animation(attacker, defender)

func _on_card_died(card: Card):
	game_view.play_death_animation(card)

# Setup helpers
func setup_test_cards():
	var test_cards = [
		["Knight", 3, 4, 3],
		["Dragon", 5, 5, 5],
		["Goblin", 2, 2, 1]
	]
	
	for card_data in test_cards:
		var card = Card.new(card_data[0], card_data[1], card_data[2], card_data[3])
		game_state.player_state.add_card_to_hand(card)
	
	game_view.update_display(game_state)
