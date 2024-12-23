# CombatManager.gd
extends Node

class_name CombatManager

var player_board: Array = []  # Array of Card instances
var opponent_board: Array = []
var max_board_size = 7

func _init():
    # Initialize empty boards
    player_board.resize(max_board_size)
    opponent_board.resize(max_board_size)

func place_card(card: CombatCard, position: int, is_player: bool = true):
    var board = player_board if is_player else opponent_board
    if position < 0 or position >= max_board_size:
        return false
    if board[position] != null:
        return false
    
    board[position] = card
    card.position_in_combat = position
    return true

func remove_card(position: int, is_player: bool = true):
    var board = player_board if is_player else opponent_board
    if position < 0 or position >= max_board_size:
        return
    board[position] = null

func execute_combat_round():
    # Process combat from left to right
    for pos in range(max_board_size):
        var attacker = player_board[pos]
        if attacker:
            var target = find_target(pos, false)  # Find opponent target
            if target:
                attacker.attack_target(target)
                if target.health <= 0:
                    remove_card(target.position_in_combat, false)
    
    # Opponent attacks back
    for pos in range(max_board_size):
        var attacker = opponent_board[pos]
        if attacker:
            var target = find_target(pos, true)  # Find player target
            if target:
                attacker.attack_target(target)
                if target.health <= 0:
                    remove_card(target.position_in_combat, true)

func find_target(attacker_pos: int, target_is_player: bool) -> CombatCard:
    var target_board = player_board if target_is_player else opponent_board
    
    # First try to find a direct opponent
    if target_board[attacker_pos]:
        return target_board[attacker_pos]
    
    # If no direct opponent, find the nearest target
    var left_pos = attacker_pos - 1
    var right_pos = attacker_pos + 1
    
    while left_pos >= 0 or right_pos < max_board_size:
        if left_pos >= 0 and target_board[left_pos]:
            return target_board[left_pos]
        if right_pos < max_board_size and target_board[right_pos]:
            return target_board[right_pos]
        left_pos -= 1
        right_pos += 1
    
    return null  # No valid target found

# Example usage
func example_combat():
    var combat = CombatManager.new()
    
    # Create some sample cards
    var knight = CombatCard.new("Knight", 3, 4, 3)
    var goblin = CombatCard.new("Goblin", 2, 2, 1)
    var dragon = CombatCard.new("Dragon", 5, 5, 5)
    
    # Place cards on the boards
    combat.place_card(knight, 0, true)  # Player's knight at position 0
    combat.place_card(goblin, 1, false) # Opponent's goblin at position 1
    combat.place_card(dragon, 2, false)  # Opponent's dragon at position 2
    
    # Execute a combat round
    combat.execute_combat_round()

func get_card_position(card: CombatCard) -> int:
    for i in range(player_board.size()):
        if player_board[i] == card:
            return i
    return -1

func get_card_at_position(position: int, is_player: bool = true) -> CombatCard:
    var board = player_board if is_player else opponent_board
    return board[position] if position >= 0 and position < board.size() else null

func swap_cards(pos1: int, pos2: int):
    var temp = player_board[pos1]
    player_board[pos1] = player_board[pos2]
    player_board[pos2] = temp
    
    if player_board[pos1]:
        player_board[pos1].position_in_combat = pos1
    if player_board[pos2]:
        player_board[pos2].position_in_combat = pos2

func move_card(from_pos: int, to_pos: int):
    player_board[to_pos] = player_board[from_pos]
    player_board[from_pos] = null
    if player_board[to_pos]:
        player_board[to_pos].position_in_combat = to_pos