extends Node2D

var game_state: GameState
var game_view: GameView
var game_controller: GameController

func _ready():
	setup_test_environment()
	add_test_controls()

func setup_test_environment():
	print("Starting test environment setup...")
	
	# Create game state first
	game_state = GameState.new()
	print("GameState created:", game_state)
	
	# Create and add view to scene tree
	var scene_path = "res://scenes/GameView.tscn"
	print("Attempting to load GameView scene from:", scene_path)
	
	var scene = load(scene_path)
	if scene:
		print("GameView scene loaded successfully")
		game_view = scene.instantiate()
		add_child(game_view)
		print("GameView instantiated and added to tree:", game_view)
		
		# Wait for view to be ready
		await game_view.ready
		print("GameView ready signal received")
		
		if !game_view.player_hand or !game_view.player_board:
			push_error("GameView zones not properly initialized!")
			return
			
		print("GameView zones verified")
	else:
		push_error("Failed to load GameView scene from path: " + scene_path)
		return
	
	print("Creating GameController...")
	game_controller = GameController.new(game_state, game_view)
	print("GameController created:", game_controller)
	
	# Add test cards
	add_test_cards()
	print("Test environment setup complete!")

func add_test_cards():
	print("Adding test cards...")
	var test_cards = [
		["Knight", 3, 4, 3],
		["Dragon", 5, 5, 5],
		["Goblin", 2, 2, 1]
	]
	
	for card_data in test_cards:
		var card = Card.new(card_data[0], card_data[1], card_data[2], card_data[3])
		game_state.player_state.add_card_to_hand(card)
	
	print("Updating game view...")
	game_view.update_display(game_state)
	print("Test cards added and displayed")

# Visual test helpers
func add_test_controls():
	var control_panel = VBoxContainer.new()
	control_panel.position = Vector2(10, 10)
	
	# Make sure the control panel is on top
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100  # Put it above other UI
	add_child(canvas_layer)
	canvas_layer.add_child(control_panel)
	
	# Make the panel stand out
	var panel_bg = ColorRect.new()
	panel_bg.color = Color(0.2, 0.2, 0.2, 0.8)
	panel_bg.show_behind_parent = true
	panel_bg.mouse_filter = Control.MOUSE_FILTER_PASS  # Don't block input
	control_panel.add_child(panel_bg)
	
	# Add test buttons with proper mouse handling
	add_test_button(control_panel, "Test Drag and Drop", test_drag_and_drop)
	add_test_button(control_panel, "Test Combat", test_combat)
	add_test_button(control_panel, "Reset State", reset_state)
	
	# Size the background to match the container
	await get_tree().process_frame
	panel_bg.size = control_panel.size + Vector2(20, 20)
	panel_bg.position = -Vector2(10, 10)

func add_test_button(parent: Node, text: String, callback: Callable):
	var button = Button.new()
	button.text = text
	button.pressed.connect(callback)
	button.mouse_filter = Control.MOUSE_FILTER_STOP  # Ensure button captures clicks
	parent.add_child(button)

# Test functions
func test_drag_and_drop():
	print("Testing drag and drop functionality...")
	print("Try dragging cards between zones")
	
	# Verify zones exist before testing
	if !game_view.player_hand:
		push_error("Player hand not initialized!")
		return
	
	# Enable dragging for all cards
	for slot in game_view.player_hand.slots:
		if slot.has_card():
			var card = slot.get_card()
			if card:
				card.draggable = true
				print("Enabled dragging for card:", card.card_data.card_name)
			else:
				print("No card in slot")

func test_combat():
	print("Testing combat functionality...")
	game_controller.start_combat()

func reset_state():
	print("Resetting game state...")
	game_state = GameState.new()
	add_test_cards()
	game_view.update_display(game_state)

# Automated tests
func run_automated_tests():
	test_model()
	test_view()
	test_controller()

func test_model():
	print("Testing Model layer...")
	
	# Test card creation
	var card = Card.new("Test Card", 1, 1, 1)
	assert(card.card_name == "Test Card", "Card name should match")
	
	# Test game state
	assert(game_state.player_state.hand.size() == 3, "Should have 3 cards in hand")

func test_view():
	print("Testing View layer...")
	
	# Test zone setup
	assert(game_view.player_hand != null, "Player hand should exist")
	assert(game_view.player_board != null, "Player board should exist")
	
	# Test card views
	var hand_cards = game_view.player_hand.get_cards()
	assert(hand_cards.size() == 3, "Should have 3 card views in hand")

func test_controller():
	print("Testing Controller layer...")
	
	# Test card movement
	var card = game_state.player_state.hand[0]
	var result = game_controller.card_controller.play_card_from_hand(card, 0)
	assert(result, "Should successfully play card")
	assert(game_state.player_state.board[0] == card, "Card should be on board") 
