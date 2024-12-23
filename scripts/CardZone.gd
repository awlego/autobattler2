extends Control
class_name CardZone

var container_name: String
var accepts_drops: bool = true

func get_card_slots() -> Array[CardContainer]:
	var slots: Array[CardContainer] = []
	var hbox = get_node_or_null("MarginContainer/HBoxContainer")
	if hbox:
		for child in hbox.get_children():
			if child is CardContainer:
				slots.append(child)
	return slots

func get_cards() -> Array[CardVisual]:
	var cards: Array[CardVisual] = []
	for slot in get_card_slots():
		var card = slot.get_card()
		if card:
			cards.append(card)
	return cards 

func add_card(card: CardVisual) -> bool:
	# Find first empty slot
	for slot in get_card_slots():
		if not slot.get_card():
			slot.add_card(card)
			return true
	return false  # No empty slots found

func add_card_to_slot(card: CardVisual, slot_index: int) -> bool:
	var slots = get_card_slots()
	if slot_index >= 0 and slot_index < slots.size():
		var slot = slots[slot_index]
		if not slot.get_card():
			slot.add_card(card)
			return true
	return false

func is_full() -> bool:
	for slot in get_card_slots():
		if not slot.get_card():
			return false
	return true 