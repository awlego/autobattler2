extends Panel
class_name CardContainer

signal card_dropped(card: CardVisual, container: CardContainer, drop_position: Vector2)
signal card_hover_started(card: CardVisual)
signal card_hover_ended(card: CardVisual)

@export var accepts_drops: bool = true
@export var container_name: String = "Default"

var cards: Array[CardVisual] = []

func _ready():
    # Remove the anchoring since we're using containers for layout
    # anchor_left = 0.5
    # anchor_right = 0.5
    # anchor_top = 0.5
    # anchor_bottom = 0.5
    
    # Remove grow directions since containers will handle this
    # grow_horizontal = Control.GROW_DIRECTION_BOTH
    # grow_vertical = Control.GROW_DIRECTION_BOTH

    mouse_filter = Control.MOUSE_FILTER_PASS
    set_h_size_flags(Control.SIZE_FILL | Control.SIZE_EXPAND)
    set_v_size_flags(Control.SIZE_FILL | Control.SIZE_EXPAND)
    
    # If you need to maintain aspect ratio, you might also want to set this
    # set_grow_direction(Control.GROW_DIRECTION_BOTH)

    # custom_minimum_size = Vector2(100, 150)

func _create_slot_indicators() -> void:
    # Remove any existing indicators
    for child in get_children():
        if child.is_in_group("slot_indicator"):
            child.queue_free()
    
    # Create new indicators
    for i in range(5):  # Assuming max 5 slots, adjust as needed
        var label = Label.new()
        label.add_to_group("slot_indicator")
        label.text = str(i + 1)
        label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        label.modulate = Color(1, 1, 1, 0.3)
        add_child(label)

func _can_drop_data(_position: Vector2, data) -> bool:
    if not accepts_drops:
        return false
    return data is CardVisual

func _drop_data(_position: Vector2, data: Variant) -> void:
    emit_signal("card_dropped", data, self, get_local_mouse_position())

func add_card(card: CardVisual) -> void:
    cards.append(card)
    if not card.is_inside_tree():
        add_child(card)

func remove_card(card: CardVisual) -> void:
    cards.erase(card)
    if card.is_inside_tree() and card.get_parent() == self:
        remove_child(card)

func get_cards() -> Array[CardVisual]:
    return cards

func _to_string() -> String:
    return "CardContainer(%s)" % container_name 
