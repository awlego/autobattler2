class_name CardController
extends Node

var game_state: GameState
var game_view: GameView

func setup(state: GameState, view: GameView):
    game_state = state
    game_view = view

func handle_card_drag_started(card_view: CardView):
    print("Card drag started:", card_view.name)

func handle_card_drag_ended(card_view: CardView):
    print("Card drag ended:", card_view.name)

func handle_card_dropped(card_view: CardView, slot: CardSlotView):
    print("Card dropped:", card_view.name, "in slot:", slot.name)
    # Update game state when cards are moved between zones
    # TODO: Implement state updates for card movements

func handle_card_clicked(card_view: CardView):
    print("Card clicked:", card_view.name)
    # Handle any click-specific logic
    # TODO: Implement click handling

func handle_card_hover_started(card_view: CardView):
    print("Card hover started:", card_view.name)
    # Show card preview or tooltip
    # TODO: Implement hover effects

func handle_card_hover_ended(card_view: CardView):
    print("Card hover ended:", card_view.name)
    # Hide card preview or tooltip
    # TODO: Implement hover end effects 