class_name CardSlotView
extends Panel

signal card_dropped(card: CardView, slot: CardSlotView)

var slot_index: int
var current_card: CardView = null

func _ready():
    custom_minimum_size = Vector2(120, 160)
    mouse_filter = Control.MOUSE_FILTER_IGNORE  # Changed to IGNORE
    print("CardSlotView ready - mouse_filter:", mouse_filter)

func add_card(card: CardView):
    if current_card:
        remove_card()
    
    current_card = card
    add_child(card)
    # Center the card in the slot
    card.position = Vector2.ZERO
    print("Added card to slot:", card.card_data.card_name if card.card_data else "unknown")
    print("Card mouse_filter:", card.mouse_filter)
    return true

func remove_card() -> CardView:
    var card = current_card
    if card:
        remove_child(card)
        current_card = null
    return card

func has_card() -> bool:
    return current_card != null

func get_card() -> CardView:
    return current_card