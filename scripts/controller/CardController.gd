class_name CardController

signal card_played(card: Card, position: int)
signal card_moved(card: Card, from_pos: int, to_pos: int)
signal cards_swapped(card1: Card, pos1: int, card2: Card, pos2: int)

var game_state: GameState

func _init(state: GameState):
    game_state = state

func play_card_from_hand(card: Card, board_position: int) -> bool:
    if not game_state.player_state.hand.has(card):
        return false
    
    if board_position < 0 or board_position >= game_state.player_state.board.size():
        return false
        
    if game_state.player_state.board[board_position] != null:
        return false
    
    game_state.player_state.hand.erase(card)
    game_state.player_state.board[board_position] = card
    card_played.emit(card, board_position)
    return true

func move_card(from_pos: int, to_pos: int) -> bool:
    var board = game_state.player_state.board
    if from_pos < 0 or to_pos < 0 or from_pos >= board.size() or to_pos >= board.size():
        return false
    
    var card = board[from_pos]
    if not card:
        return false
    
    if board[to_pos]:
        # Swap cards
        var other_card = board[to_pos]
        board[from_pos] = other_card
        board[to_pos] = card
        cards_swapped.emit(card, from_pos, other_card, to_pos)
    else:
        # Simple move
        board[to_pos] = card
        board[from_pos] = null
        card_moved.emit(card, from_pos, to_pos)
    
    return true 