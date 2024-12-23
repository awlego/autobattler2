# Main.gd
extends Node2D

const CardScript = preload("res://scripts/Card.gd")
const CardVisualScript = preload("res://scripts/CardVisual.gd")

var game_ui: CanvasLayer

func _ready():
	game_ui = preload("res://scripts/GameUI.gd").new()
	add_child(game_ui)
	setup_test_game()

func setup_test_game():
	# Create some test cards
	var test_cards = [
		["Knight", 3, 4, 3],
		["Dragon", 5, 5, 5],
		["Goblin", 2, 2, 1]
	]
	
	for card_data in test_cards:
		var card = CardScript.new(card_data[0], card_data[1], card_data[2], card_data[3])
		var card_visual = CardVisualScript.new()
		card_visual.setup_card(card)
		card_visual.set_draggable(true)
		game_ui.player_hand.add_card(card_visual)
