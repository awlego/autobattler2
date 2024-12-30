extends Node2D

# Declare class variables at the top
@onready var game_state: GameState
@onready var game_view: GameView
@onready var game_controller: GameController

func _ready():
	print("\nStarting TestScene initialization...")
	setup_test_environment()
	add_test_controls()

func setup_test_environment():
	print("\nStarting test environment setup...")
	
	# Step 1: Create game state
	game_state = GameState.new()
	print("Step 1 - GameState created:", game_state)
	
	# Step 2: Create and add view to scene tree
	var scene_path = "res://scenes/GameView.tscn"
	print("Step 2 - Loading GameView from:", scene_path)
	
	var scene = load(scene_path)
	if scene:
		game_view = scene.instantiate()
		add_child(game_view)
		print("Step 2a - GameView added to tree:", game_view)
		
		# Instead of awaiting, check if it's ready
		if !game_view.player_hand or !game_view.player_board:
			push_error("Step 2 failed: GameView zones not properly initialized!")
			return false
			
		print("Step 2 complete - GameView zones verified")
	else:
		push_error("Step 2 failed: Could not load GameView scene!")
		return false
	
	# Step 3: Create and setup GameController
	print("Step 3 - Creating GameController...")
	game_controller = GameController.new()
	if not game_controller:
		push_error("Step 3 failed: Could not create GameController!")
		return false
		
	print("Step 3a - Setting up GameController...")
	game_controller.setup(game_state, game_view)
	if not game_controller.game_state or not game_controller.game_view:
		push_error("Step 3 failed: GameController setup incomplete!")
		return false
		
	print("Step 3b - Adding GameController to scene tree...")
	add_child(game_controller)
	print("Step 3c - GameController added:", game_controller)
	
	# Verify controller is properly stored
	if not is_instance_valid(game_controller):
		push_error("Step 3 failed: GameController became invalid!")
		return false
	
	# Step 4: Add test cards
	print("Step 4 - Adding test cards...")
	add_test_cards()
	
	print("Test environment setup complete!")
	return true

func add_test_cards():
	print("\nAdding test cards...")
	
	# Create test cards
	var knight = Card.new("Knight", 3, 4, 3)
	var dragon = Card.new("Dragon", 5, 5, 3)
	var goblin = Card.new("Goblin", 2, 2, 1)
	var orc = Card.new("Orc", 4, 3, 2)
	var troll = Card.new("Troll", 3, 6, 4)
	
	# Add cards to game state
	game_state.player_state.board.append(knight)
	game_state.player_state.board.append(dragon)
	game_state.player_state.board.append(goblin)
	
	game_state.opponent_state.board.append(orc)
	game_state.opponent_state.board.append(troll)
	
	# Update view to reflect state
	game_view.update_display(game_state)
	
	print("Test cards added to game state and view updated")

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
	print("\nDEBUG: Starting combat test")
	print("DEBUG: game_controller =", game_controller)
	print("DEBUG: All nodes in scene:")
	for child in get_children():
		print(" - ", child.name, " (", child.get_class(), ")")
	
	if not game_controller:
		push_error("GameController is null! Cannot test combat.")
		return
	if not game_controller.game_state:
		push_error("GameController state is null! Cannot test combat.")
		return
	if not game_controller.game_view:
		push_error("GameController view is null! Cannot test combat.")
		return
		
	print("Starting combat with controller:", game_controller)
	game_controller.start_combat()

func reset_state():
	print("Resetting game state...")
	
	# Remove existing controller and view
	if game_controller:
		game_controller.queue_free()
	if game_view:
		game_view.queue_free()
		
	# Setup fresh environment
	setup_test_environment()
	add_test_controls()  # Re-add the test controls
	print("Game state reset complete")

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
