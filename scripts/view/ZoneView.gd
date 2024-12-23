class_name ZoneView
extends Control

signal card_drag_started(card: CardView, zone: ZoneView)
signal card_dropped(card: CardView, slot: CardSlotView)

var zone_name: String
var accepts_drops: bool = true
var slots: Array[CardSlotView] = []

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	setup_slots()
	setup_visuals()
	print("ZoneView ready - mouse_filter:", mouse_filter)

func setup_visuals():
	# Add background with proper sizing
	var background = ColorRect.new()
	background.color = Color(0.2, 0.2, 0.2, 0.3)
	background.anchor_right = 1.0
	background.anchor_bottom = 1.0
	background.mouse_filter = Control.MOUSE_FILTER_PASS  # Don't block input
	add_child(background)

func setup_slots():
	# Create margin container for padding
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.anchor_right = 1.0
	margin.anchor_bottom = 1.0
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(margin)
	
	# Create container for slots
	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(hbox)
	
	print("Setting up slots in ZoneView:", zone_name)
	for i in range(5):
		var slot = CardSlotView.new()
		slot.slot_index = i
		slot.custom_minimum_size = Vector2(120, 160)
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.card_dropped.connect(_on_slot_card_dropped)
		hbox.add_child(slot)
		slots.append(slot)
		print("Created slot", i, "with mouse_filter:", slot.mouse_filter)

func _on_slot_card_dropped(card: CardView, slot: CardSlotView):
	if accepts_drops:
		# Remove card from its current slot if it's in one
		if card.get_parent() is CardSlotView:
			card.get_parent().remove_card()
		
		# Add card to new slot
		if slot.add_card(card):
			card_dropped.emit(card, slot)

func get_cards() -> Array[CardView]:
	var cards: Array[CardView] = []
	for slot in slots:
		if slot.has_card():
			cards.append(slot.get_card())
	return cards
