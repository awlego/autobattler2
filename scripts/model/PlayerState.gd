class_name PlayerState

var hand: Array[Card] = []
var board: Array[Card] = []
var deck: Array[Card] = []

func add_card_to_hand(card: Card):
	hand.append(card)

func add_card_to_board(card: Card):
	board.append(card)

func remove_card(card: Card):
	hand.erase(card)
	board.erase(card)
	deck.erase(card)

func play_card(card: Card, position: int) -> bool:
	if not hand.has(card) or position >= 7:
		return false
	hand.erase(card)
	board.insert(position, card)
	return true 
