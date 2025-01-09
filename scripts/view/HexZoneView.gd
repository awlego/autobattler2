class_name HexZoneView
extends Control

signal card_drag_started(card: CardView, zone: HexZoneView)
signal card_dropped(card: CardView, slot: CardSlotView)

var zone_name: String
var accepts_drops: bool = true
var hex_map: HexMap
var hex_slots: Dictionary = {}  # Key: Vector3 (hex_coord) -> Value: CardSlotView

# Add this property to maintain compatibility with the array-based access
var slots: Array[CardSlotView]:
	get:
		var slot_array: Array[CardSlotView] = []
		slot_array.assign(hex_slots.values())
		return slot_array

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	setup_hex_grid()
	setup_visuals()

func setup_visuals():
	# Add background with proper sizing
	var background = ColorRect.new()
	background.color = Color(0.2, 0.2, 0.2, 0.3)
	background.anchor_right = 1.0
	background.anchor_bottom = 1.0
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.z_index = -1
	add_child(background)

func setup_hex_grid():
	hex_map = HexMap.new()
	hex_map.size = Vector2(60, 60)  # Adjust hex size as needed
	add_child(hex_map)
	
	# Create a test pattern (can be customized per zone)
	var pattern = get_zone_pattern()
	for hex_coord in pattern:
		create_hex_slot(hex_coord)

func get_zone_pattern() -> Array[Vector3]:
	match zone_name:
		"player_hand":
			return _get_hand_pattern()
		"player_board", "opponent_board":
			return _get_board_pattern()
		_:
			return _get_default_pattern()

func _get_hand_pattern() -> Array[Vector3]:
	# Single row pattern for hand
	var pattern: Array[Vector3] = []
	for q in range(-2, 3):
		pattern.append(Vector3(q, 0, -q))
	return pattern

func _get_board_pattern() -> Array[Vector3]:
	# Hexagonal pattern for board
	var pattern: Array[Vector3] = []
	for q in range(-2, 3):
		for r in range(-2, 3):
			var hex = Vector3(q, r, -q-r)
			if abs(hex.z) <= 2:  # Creates a hexagonal shape
				pattern.append(hex)
	return pattern

func _get_default_pattern() -> Array[Vector3]:
	# Fallback pattern
	return _get_board_pattern()

func create_hex_slot(hex_coord: Vector3):
	var slot = CardSlotView.new()
	var pixel_pos = hex_map.hex_to_pixel(hex_coord)
	slot.position = pixel_pos
	slot.slot_index = hex_slots.size()  # Assign index when creating slot
	slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.card_dropped.connect(_on_slot_card_dropped)
	add_child(slot)
	hex_slots[hex_coord] = slot

func _on_slot_card_dropped(card: CardView, slot: CardSlotView):
	if accepts_drops:
		if card.get_parent() is CardSlotView:
			card.get_parent().remove_card()
		if slot.add_card(card):
			card_dropped.emit(card, slot)

func get_cards() -> Array[CardView]:
	var cards: Array[CardView] = []
	for slot in hex_slots.values():
		if slot.has_card():
			cards.append(slot.get_card())
	return cards

func _draw():
	# Draw hex grid
	if hex_map:
		for hex_coord in hex_slots.keys():
			var corners = hex_map.hex_corners(hex_coord)
			# Draw hex outline
			for i in range(corners.size() - 1):
				draw_line(corners[i], corners[i + 1], Color(1, 1, 1, 0.2), 1.0)
			
			# Draw hex fill if slot has a card
			var slot = hex_slots[hex_coord]
			if slot.has_card():
				var points = PackedVector2Array(corners)
				draw_colored_polygon(points, Color(0.3, 0.3, 0.3, 0.3))

func get_hex_at_position(pos: Vector2) -> Vector3:
	return hex_map.pixel_to_hex(pos - position)

func get_slot_at_hex(hex_coord: Vector3) -> CardSlotView:
	return hex_slots.get(hex_coord)

func highlight_hex(hex_coord: Vector3, highlight: bool = true):
	if hex_slots.has(hex_coord):
		var slot = hex_slots[hex_coord]
		# TODO: Implement highlighting visual effect
		queue_redraw() 
