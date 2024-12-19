# Main.gd
extends Node2D

const CombatVisualManager = preload("res://scripts/CombatVisualManager.gd")

func _ready():
	# Create the combat visual manager
	var combat_visual = CombatVisualManager.new()
	add_child(combat_visual)
	
	# The combat manager is automatically created inside CombatVisualManager
	# in its _ready() function, so we don't need to create it here
	
	# The setup_test_battle() function in CombatVisualManager will handle:
	# 1. Creating the cards
	# 2. Placing them in the combat manager
	# 3. Creating their visuals
	
	# The combat button is also automatically created in CombatVisualManager's
	# _ready() function, which will trigger combat when clicked
