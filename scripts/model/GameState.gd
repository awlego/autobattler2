class_name GameState

signal state_changed

var player_state: PlayerState
var opponent_state: PlayerState

func _init():
	player_state = PlayerState.new()
	opponent_state = PlayerState.new()

# Helper methods to access common state
var player_board: Array:
	get: return player_state.board
	
var opponent_board: Array:
	get: return opponent_state.board
	
var player_hand: Array:
	get: return player_state.hand

func remove_card(card: Card):
	# Try to remove from all possible locations
	player_state.remove_card(card)
	opponent_state.remove_card(card)
	state_changed.emit()
