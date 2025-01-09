# Main.gd
extends Node2D

var game_state: GameState
var game_view: GameView
var game_controller: GameController

func _ready():
	setup_game()

func setup_game():
	game_state = GameState.new()
	game_view = preload("res://scenes/GameView.tscn").instantiate()
	add_child(game_view)
