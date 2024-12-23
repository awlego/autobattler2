extends CanvasLayer
class_name GameUI
var player_hand: CardZone
var player_board: CardZone
var opponent_board: CardZone

func _ready():
	setup_containers()
	connect_signals()

func setup_containers():
	# Create main vertical container
	var main_container = VBoxContainer.new()
	main_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_container.add_theme_constant_override("separation", 20)
	
	# Add margins around the main container
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)  # Make margin container fill screen
	margin.add_theme_constant_override("margin_left", 50)
	margin.add_theme_constant_override("margin_right", 50)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	
	# Create containers with the same styling as before
	opponent_board = create_board("OpponentBoard", Color(0.4, 0.2, 0.2, 0.3), Color(1, 0, 0, 0.5))
	player_board = create_board("PlayerBoard", Color(0.2, 0.4, 0.2, 0.3), Color(0, 1, 0, 0.5))
	player_hand = create_board("PlayerHand", Color(0.2, 0.2, 0.2, 0.3), Color(1, 0.8, 0, 0.5))
	
	# Set size flags to expand both horizontally AND vertically
	opponent_board.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	opponent_board.size_flags_vertical = Control.SIZE_EXPAND_FILL
	player_board.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	player_board.size_flags_vertical = Control.SIZE_EXPAND_FILL
	player_hand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	player_hand.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	# Set the main container to also expand vertically
	main_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	opponent_board.accepts_drops = false
	
	# Add all containers to the main vertical container
	main_container.add_child(opponent_board)
	main_container.add_child(player_board)
	main_container.add_child(player_hand)
	
	# Add the margin container to the scene
	margin.add_child(main_container)
	add_child(margin)

func create_board(board_name: String, bg_color: Color, border_color: Color) -> CardZone:
	var container = CardZone.new()
	container.container_name = board_name
	container.name = board_name
	
	# Create a panel to ensure we see the background
	var panel = Panel.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	# Make sure the panel styling is visible
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(2)
	style.set_corner_radius_all(5)
	style.draw_center = true
	
	panel.add_theme_stylebox_override("panel", style)
	container.add_child(panel)
	
	# Add the grid on top of the panel
	var hbox = HBoxContainer.new()
	hbox.set_h_size_flags(Control.SIZE_FILL | Control.SIZE_EXPAND)
	hbox.set_v_size_flags(Control.SIZE_FILL | Control.SIZE_EXPAND)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	# Add card slots to the hbox
	for i in range(7):
		var slot = CardContainer.new()
		slot.container_name = board_name + "_slot_" + str(i)
		slot.custom_minimum_size = Vector2(140, 210)
		hbox.add_child(slot)
	
	# Add some padding around the hbox
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	
	margin.add_child(hbox)
	container.add_child(margin)
	
	return container

func connect_signals():
	for slot in player_hand.get_card_slots():
		slot.card_dropped.connect(_on_card_dropped)
	for slot in player_board.get_card_slots():
		slot.card_dropped.connect(_on_card_dropped)

func _on_card_dropped(card: CardVisual, container: CardContainer, drop_position: Vector2):
	var source_container = card.get_parent()
	if source_container == container:
		return
		
	source_container.remove_card(card)
	container.add_card(card)
	
	# Position cards in the container
	organize_container(container)

func organize_container(container: CardContainer):
	var cards = container.get_cards()
	var spacing = 130  # Adjust based on card width + margin
	var start_x = 0
	
	for i in range(cards.size()):
		var card = cards[i]
		var target_pos = Vector2(start_x + (i * spacing), 0)
		card.position = target_pos
