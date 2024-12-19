extends Node2D

const ZONE_WIDTH = 800
const ZONE_HEIGHT = 150
const SLOT_SIZE = Vector2(120, 160)
const NUM_SLOTS = 5
const ZONE_COLOR = Color(0.2, 0.2, 0.2, 0.3)
const SLOT_COLOR = Color(1, 1, 1, 0.2)

var player_slots: Array[Node2D] = []
var opponent_slots: Array[Node2D] = []

func setup_zones(start_x: float, player_y: float, opponent_y: float):
	# Create zones container
	var zones = Node2D.new()
	add_child(zones)
	
	# Create player zone
	var player_zone = create_zone(player_y - ZONE_HEIGHT/2, start_x)
	zones.add_child(player_zone)
	
	# Create opponent zone
	var opponent_zone = create_zone(opponent_y - ZONE_HEIGHT/2, start_x)
	zones.add_child(opponent_zone)
	
	# Create card slots
	create_card_slots(start_x, player_y, opponent_y)

func create_zone(y_position: float, start_x: float) -> Node2D:
	var zone = Node2D.new()
	zone.draw.connect(func():
		var rect = Rect2(
			Vector2(start_x - 50, 0),
			Vector2(ZONE_WIDTH, ZONE_HEIGHT)
		)
		zone.draw_rect(rect, ZONE_COLOR, true)
	)
	
	zone.position.y = y_position
	zone.queue_redraw()
	return zone

func create_card_slots(start_x: float, player_y: float, opponent_y: float):
	# Calculate the total width needed for all slots
	var total_slots_width = (NUM_SLOTS - 1) * 150 + SLOT_SIZE.x
	# Calculate starting x position to center the slots in the zone
	var slots_start_x = start_x + (ZONE_WIDTH - total_slots_width) / 2

	for i in range(NUM_SLOTS):
		# Player slots
		var player_slot = create_slot(i + 1)
		player_slot.position = Vector2(
				slots_start_x + (i * 150), # Using fixed card spacing
				player_y - SLOT_SIZE.y/2
		)
		add_child(player_slot)
		player_slots.append(player_slot)
		
		# Opponent slots
		var opponent_slot = create_slot(i + 1)
		opponent_slot.position = Vector2(
				slots_start_x + (i * 150), # Using fixed card spacing
				opponent_y - SLOT_SIZE.y/2
		)
		add_child(opponent_slot)
		opponent_slots.append(opponent_slot)

func create_slot(number: int) -> Node2D:
	var slot = Node2D.new()
	
	# Create the visual rectangle
	slot.draw.connect(func():
		var rect = Rect2(
			Vector2(-SLOT_SIZE.x/2, 0),
			SLOT_SIZE
		)
		slot.draw_rect(rect, SLOT_COLOR, true)
	)
	
	# Add centered label
	var label = Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.custom_minimum_size = SLOT_SIZE
	label.position = Vector2(-SLOT_SIZE.x/2, 0)  # Align with slot rectangle
	label.text = str(number)
	label.add_theme_font_size_override("font_size", 32)
	slot.add_child(label)
	
	slot.queue_redraw()
	return slot 