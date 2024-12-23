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
	
	game_controller = GameController.new(game_state, game_view)
	game_controller.start_game()
	
	# Add combat button
	var combat_button = Button.new()
	combat_button.text = "Start Combat"
	combat_button.position = Vector2(900, 900)
	combat_button.pressed.connect(game_controller.start_combat)
	add_child(combat_button)
