class_name GameState

signal state_changed

var player_state: PlayerState
var opponent_state: PlayerState
var current_phase: String

func _init():
    player_state = PlayerState.new()
    opponent_state = PlayerState.new()
    current_phase = "setup"

func update_state():
    state_changed.emit() 