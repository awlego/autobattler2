class_name CardSlotView
extends Panel

signal card_dropped(card: CardView, slot: CardSlotView)

var slot_index: int
var current_card: CardView = null
var debug_label: Label

func _ready():
	custom_minimum_size = Vector2(120, 160)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_to_group("card_slots")  # Add to group for easy finding
	
	# Add debug label
	debug_label = Label.new()
	debug_label.add_theme_color_override("font_color", Color.GREEN)
	debug_label.position = Vector2(0, 160)  # Below slot
	add_child(debug_label)
	
	update_debug_label()
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func update_debug_label():
	if debug_label:
		var card_name = current_card.name if current_card else "EMPTY"
		debug_label.text = "[Slot %d] Card: %s" % [slot_index, card_name]

func can_accept_card(card: CardView) -> bool:
	return not has_card()  # Can accept if we don't already have a card

func _on_mouse_entered():
	if not has_card() and get_tree().get_nodes_in_group("dragging_cards").size() > 0:
		modulate = Color(1.2, 1.2, 1.2)  # Highlight valid drop targets

func _on_mouse_exited():
	modulate = Color.WHITE

# Add this to handle drops
func _can_drop_data(_pos, data):
	return data is CardView and not has_card()

func _drop_data(_pos, data):
	if data is CardView:
		add_card(data)
		card_dropped.emit(data, self)

func add_card(card: CardView):
	if current_card:
		remove_card()
	
	# Check if card is already in another slot
	var old_slot = card.get_parent()
	if old_slot is CardSlotView:
		old_slot.clear_card_reference()
	
	current_card = card
	add_child(card)
	card.position = Vector2.ZERO
	print("Added card to slot:", card.card_data.card_name if card.card_data else "unknown")
	update_debug_label()
	return true

func remove_card() -> CardView:
	var card = current_card
	if card:
		remove_child(card)
		clear_card_reference()
	return card

func has_card() -> bool:
	return current_card != null

func get_card() -> CardView:
	return current_card

func clear_card_reference():
	print("Clearing card reference from slot", slot_index)
	current_card = null
	update_debug_label()
