class_name PlayerState

var hand: Array[Card] = []
var board: Array[Card] = []
var health: int = 20
var mana: int = 0

func add_card_to_hand(card: Card):
    hand.append(card)

func play_card(card: Card, position: int) -> bool:
    if not hand.has(card) or position >= 7:
        return false
    hand.erase(card)
    board.insert(position, card)
    return true 