# CardTestScene.gd
extends Node2D

# Reference to our card script
const CardScript = preload("res://scripts/Card.gd")
const CardVisualScript = preload("res://scripts/CardVisual.gd")

func _ready():
	setup_test_cards()
	create_test_buttons()

func setup_test_cards():
	# Create some sample cards with different stats
	var test_cards = [
		["Knight", 3, 4, 3],
		["Dragon", 5, 5, 5],
		["Goblin", 2, 2, 1]
	]
	
	# Spawn cards in a horizontal line
	for i in range(test_cards.size()):
		var card_data = test_cards[i]
		var card = CardScript.new(card_data[0], card_data[1], card_data[2], card_data[3])
		
		var card_visual = CardVisualScript.new()
		add_child(card_visual)
		card_visual.position = Vector2(150 + i * 150, 200)  # Space cards horizontally
		card_visual.setup_card(card)

func create_test_buttons():
	# Create a VBox for buttons
	var button_container = VBoxContainer.new()
	button_container.position = Vector2(50, 400)
	add_child(button_container)
	
	# Attack Animation Test Button
	var attack_button = Button.new()
	attack_button.text = "Test Attack Animation"
	attack_button.custom_minimum_size = Vector2(150, 30)
	attack_button.pressed.connect(_test_attack_animation)
	button_container.add_child(attack_button)
	
	# Damage Animation Test Button
	var damage_button = Button.new()
	damage_button.text = "Test Damage Animation"
	damage_button.custom_minimum_size = Vector2(150, 30)
	damage_button.pressed.connect(_test_damage_animation)
	button_container.add_child(damage_button)
	
	# Death Animation Test Button
	var death_button = Button.new()
	death_button.text = "Test Death Animation"
	death_button.custom_minimum_size = Vector2(150, 30)
	death_button.pressed.connect(_test_death_animation)
	button_container.add_child(death_button)

func _test_attack_animation():
	for card in get_tree().get_nodes_in_group("cards"):
		if card is CardVisualScript:
			card.play_attack_animation()

func _test_damage_animation():
	for card in get_tree().get_nodes_in_group("cards"):
		if card is CardVisualScript:
			card.play_damage_animation()

func _test_death_animation():
	for card in get_tree().get_nodes_in_group("cards"):
		if card is CardVisualScript:
			card.play_death_animation()