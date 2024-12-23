class_name CombatController

signal combat_round_started
signal combat_round_ended
signal card_attacked(attacker: Card, defender: Card)
signal card_died(card: Card)

var game_state: GameState

func _init(state: GameState):
    game_state = state

func execute_combat_round():
    combat_round_started.emit()
    
    # Process player attacks
    for pos in range(game_state.player_state.board.size()):
        var attacker = game_state.player_state.board[pos]
        if attacker:
            var target = find_target(pos, false)
            if target:
                card_attacked.emit(attacker, target)
                attacker.attack_target(target)
                if target.health <= 0:
                    card_died.emit(target)
                    game_state.opponent_state.board[target.get_position()] = null
    
    # Process opponent attacks
    for pos in range(game_state.opponent_state.board.size()):
        var attacker = game_state.opponent_state.board[pos]
        if attacker:
            var target = find_target(pos, true)
            if target:
                card_attacked.emit(attacker, target)
                attacker.attack_target(target)
                if target.health <= 0:
                    card_died.emit(target)
                    game_state.player_state.board[target.get_position()] = null
    
    combat_round_ended.emit()

func find_target(attacker_pos: int, targeting_player: bool) -> Card:
    var defending_board = game_state.player_state.board if targeting_player else game_state.opponent_state.board
    
    # First check direct opposite
    if defending_board[attacker_pos]:
        return defending_board[attacker_pos]
    
    # Then check adjacent positions
    for offset in [1, -1]:
        var check_pos = attacker_pos + offset
        if check_pos >= 0 and check_pos < defending_board.size():
            if defending_board[check_pos]:
                return defending_board[check_pos]
    
    return null 