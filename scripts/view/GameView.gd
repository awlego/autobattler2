class_name GameView
extends CanvasLayer

signal card_drag_started(card: Card, from_zone: String)
signal card_dropped(card: Card, to_zone: String, position: int)

var player_hand: ZoneView
var player_board: ZoneView
var opponent_board: ZoneView
var card_controller: CardController

const ZONE_WIDTH = 800
const ZONE_HEIGHT = 200
const ZONE_SPACING = 50

func _ready():
	print("GameView _ready called")
	setup_zones()
	connect_signals()
	print("GameView zones setup complete")
	print("player_hand:", player_hand)
	print("player_board:", player_board)

func setup_zones():
	print("Setting up zones...")
	
	# Create a MarginContainer for padding from screen edges
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 200)
	margin.add_theme_constant_override("margin_right", 200)
	margin.add_theme_constant_override("margin_top", 50)
	margin.add_theme_constant_override("margin_bottom", 50)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Changed to IGNORE
	add_child(margin)
	
	# Create a VBoxContainer to hold all zones with proper spacing
	var layout = VBoxContainer.new()
	layout.add_theme_constant_override("separation", ZONE_SPACING)
	layout.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Changed to IGNORE
	margin.add_child(layout)
	
	# Setup opponent board (top)
	opponent_board = ZoneView.new()
	opponent_board.zone_name = "opponent_board"
	opponent_board.accepts_drops = false
	opponent_board.custom_minimum_size = Vector2(ZONE_WIDTH, ZONE_HEIGHT)
	layout.add_child(opponent_board)
	
	# Setup player board (middle)
	player_board = ZoneView.new()
	player_board.zone_name = "player_board"
	player_board.custom_minimum_size = Vector2(ZONE_WIDTH, ZONE_HEIGHT)
	layout.add_child(player_board)
	
	# Setup player hand (bottom)
	player_hand = ZoneView.new()
	player_hand.zone_name = "player_hand"
	player_hand.custom_minimum_size = Vector2(ZONE_WIDTH, ZONE_HEIGHT)
	layout.add_child(player_hand)
	
	print("Debug - player_hand mouse_filter:", player_hand.mouse_filter)

func connect_signals():
	# Connect zone signals for drag and drop
	player_hand.card_drag_started.connect(_on_zone_card_drag_started.bind("hand"))
	player_hand.card_dropped.connect(_on_zone_card_dropped.bind("hand"))
	
	player_board.card_drag_started.connect(_on_zone_card_drag_started.bind("board"))
	player_board.card_dropped.connect(_on_zone_card_dropped.bind("board"))

func _on_zone_card_drag_started(card_view: CardView, zone: ZoneView, from_zone: String):
	card_drag_started.emit(card_view.card_data, from_zone)

func _on_zone_card_dropped(card_view: CardView, slot: CardSlotView, from_zone: String):
	var to_zone = "hand" if slot.get_parent().get_parent() == player_hand else "board"
	card_dropped.emit(card_view.card_data, to_zone, slot.slot_index)

func highlight_valid_zones(card: Card, from_zone: String):
	# Add visual feedback for valid drop zones
	if from_zone == "hand":
		player_board.modulate = Color(1.2, 1.2, 1.2)
	elif from_zone == "board":
		player_board.modulate = Color(1.2, 1.2, 1.2)
		player_hand.modulate = Color(1.2, 1.2, 1.2)

func clear_highlights():
	player_hand.modulate = Color.WHITE
	player_board.modulate = Color.WHITE

func disable_interactions():
	player_hand.accepts_drops = false
	player_board.accepts_drops = false

func enable_interactions():
	player_hand.accepts_drops = true
	player_board.accepts_drops = true

func update_display(game_state: GameState):
	update_hand(game_state.player_state.hand)
	update_board(game_state.player_state.board, game_state.opponent_state.board)

func update_hand(cards: Array[Card]):
	# Clear existing cards
	for slot in player_hand.slots:
		if slot.has_card():
			slot.remove_card().queue_free()
	
	# Add new cards
	for i in range(cards.size()):
		var card = cards[i]
		var card_view = CardView.new()
		card_view.card_data = card
		player_hand.slots[i].add_card(card_view)

func update_board(player_cards: Array[Card], opponent_cards: Array[Card]):
	# Clear existing cards
	for slot in player_board.slots:
		if slot.has_card():
			slot.remove_card().queue_free()
	
	for slot in opponent_board.slots:
		if slot.has_card():
			slot.remove_card().queue_free()
	
	# Add new cards
	for i in range(player_cards.size()):
		var card = player_cards[i]
		if card:
			var card_view = CardView.new()
			card_view.card_data = card
			player_board.slots[i].add_card(card_view)
	
	for i in range(opponent_cards.size()):
		var card = opponent_cards[i]
		if card:
			var card_view = CardView.new()
			card_view.card_data = card
			card_view.is_player_card = false
			card_view.draggable = false
			opponent_board.slots[i].add_card(card_view)

func play_attack_animation(attacker: Card, defender: Card):
	# Find the card views
	var attacker_view = _find_card_view(attacker)
	var defender_view = _find_card_view(defender)
	
	if attacker_view and defender_view:
		attacker_view.play_attack_animation()
		defender_view.play_damage_animation()

func play_death_animation(card: Card):
	var card_view = _find_card_view(card)
	if card_view:
		card_view.play_death_animation()

func _find_card_view(card: Card) -> CardView:
	# Search through all zones for the card
	for zone in [player_hand, player_board, opponent_board]:
		for slot in zone.slots:
			if slot.has_card() and slot.get_card().card_data == card:
				return slot.get_card()
	return null
