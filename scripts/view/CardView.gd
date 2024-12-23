class_name CardView
extends Control

signal drag_started(card: CardView)
signal drag_ended(card: CardView)

var card_data: Card
var is_player_card: bool = true
var draggable: bool = true
var dragging: bool = false
var drag_offset: Vector2
var original_parent: Node

# Store label references
var name_label: Label
var attack_label: Label
var health_label: Label
var cost_label: Label

const CARD_WIDTH = 120
const CARD_HEIGHT = 160

var drag_start_position: Vector2
const DRAG_THRESHOLD = 5.0  # Pixels of movement required to start drag
var drag_enabled = false  # Track if we're holding the card

var hold_timer: float = 0.0
var holding: bool = false

var debug_label: Label

func _ready():
	custom_minimum_size = Vector2(CARD_WIDTH, CARD_HEIGHT)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Ensure cards are always on top
	z_index = 1
	z_as_relative = false  # Make z_index global
	
	# Make card clickable
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	# Connect to input events
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	# Add debug label
	debug_label = Label.new()
	debug_label.add_theme_color_override("font_color", Color.YELLOW)
	debug_label.position = Vector2(0, -20)  # Above card
	add_child(debug_label)
	
	construct_visual()
	update_display()
	update_debug_label()

func _on_gui_input(event: InputEvent):
	# Only print non-motion events to reduce spam
	if not (event is InputEventMouseMotion):
		print("Card received input:", event)
	
	if not draggable:
		return
		
	if event is InputEventMouseButton:
		print("Card received mouse button:", event.button_index, " pressed:", event.pressed)
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				holding = true
				start_drag()
			else:
				holding = false
				if dragging:
					end_drag()
			get_viewport().set_input_as_handled()

func construct_visual():
	# Background
	var background = ColorRect.new()
	background.color = Color(0.3, 0.3, 0.3, 1.0)
	background.size = size
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	
	# Art placeholder
	var art_placeholder = ColorRect.new()
	art_placeholder.color = Color(randf(), randf(), randf(), 1.0)
	art_placeholder.size = Vector2(size.x - 20, size.y * 0.6)
	art_placeholder.position = Vector2(10, 10)
	art_placeholder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(art_placeholder)
	
	# Name label in center
	name_label = Label.new()
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.size = Vector2(size.x, 30)
	name_label.position = Vector2(0, art_placeholder.position.y + art_placeholder.size.y + 5)
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(name_label)
	
	# Stats boxes with backgrounds
	var cost_box = ColorRect.new()
	cost_box.color = Color(0.2, 0.6, 0.8)  # Blue for cost
	cost_box.size = Vector2(30, 30)
	cost_box.position = Vector2(5, 5)
	add_child(cost_box)
	
	cost_label = Label.new()
	cost_label.add_theme_color_override("font_color", Color.WHITE)
	cost_label.text = "0"
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cost_label.size = cost_box.size
	cost_label.position = cost_box.position
	cost_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(cost_label)
	
	var attack_box = ColorRect.new()
	attack_box.color = Color(0.8, 0.2, 0.2)  # Red for attack
	attack_box.size = Vector2(30, 30)
	attack_box.position = Vector2(5, size.y - 35)
	add_child(attack_box)
	
	attack_label = Label.new()
	attack_label.add_theme_color_override("font_color", Color.WHITE)
	attack_label.text = "0"
	attack_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	attack_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	attack_label.size = attack_box.size
	attack_label.position = attack_box.position
	attack_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(attack_label)
	
	var health_box = ColorRect.new()
	health_box.color = Color(0.2, 0.8, 0.2)  # Green for health
	health_box.size = Vector2(30, 30)
	health_box.position = Vector2(size.x - 35, size.y - 35)
	add_child(health_box)
	
	health_label = Label.new()
	health_label.add_theme_color_override("font_color", Color.WHITE)
	health_label.text = "0"
	health_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	health_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	health_label.size = health_box.size
	health_label.position = health_box.position
	health_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(health_label)

func update_display():
	if card_data:
		name_label.text = card_data.card_name
		attack_label.text = str(card_data.attack)
		health_label.text = str(card_data.health)
		cost_label.text = str(card_data.cost)

func start_drag():
	print("Starting drag operation...")
	dragging = true
	drag_offset = get_local_mouse_position()
	original_parent = get_parent()
	
	# If we're in a slot, tell it we're leaving
	if original_parent is CardSlotView:
		original_parent.clear_card_reference()  # New method
	
	# Store the global position before reparenting
	var global_pos = global_position
	
	# Get the viewport root
	var viewport_node = get_tree().root
	if viewport_node:
		print("Found viewport, reparenting card")
		# Remove from current parent
		original_parent.remove_child(self)
		
		# Add to viewport root
		viewport_node.add_child(self)
		
		# Restore position and ensure we stay on top
		global_position = global_pos
		z_index = 100
		
		# Visual feedback
		modulate = Color(1.2, 1.2, 1.2)
		
		drag_started.emit(self)
	else:
		push_error("Could not find viewport for drag operation")
		dragging = false

func end_drag():
	print("Ending drag operation...")
	if !dragging:
		return
		
	dragging = false
	modulate = Color.WHITE  # Reset brightness
	
	# Find the closest slot
	var closest_slot: CardSlotView = null
	var min_distance: float = 1000000
	
	# Get all slots from the game
	var slots = get_tree().get_nodes_in_group("card_slots")
	print("Found", slots.size(), "potential slots")
	
	for slot in slots:
		var distance = global_position.distance_to(slot.global_position)
		if distance < min_distance:
			min_distance = distance
			closest_slot = slot
	
	# If we found a valid slot within range, move to it
	if closest_slot and min_distance < 100:  # Adjust threshold as needed
		print("Found closest slot:", closest_slot.name, "at distance:", min_distance)
		print("Slot has card:", closest_slot.current_card != null)
		
		# Always attempt the swap
		print("Attempting swap with slot:", closest_slot.name)
		var displaced_card = closest_slot.add_card_with_swap(self)
		
		# If we displaced a card, move it to our original slot
		if displaced_card:
			print("Moving displaced card", displaced_card.name, "to original slot")
			original_parent.add_card(displaced_card)
		else:
			print("No card was displaced during swap")
		
		drag_ended.emit(self)
		return
	
	# If no valid slot found, return to original slot
	print("No valid slot found, returning to original slot")
	if is_instance_valid(original_parent):
		var current_parent = get_parent()
		if current_parent:
			current_parent.remove_child(self)
		original_parent.add_card(self)
	else:
		push_error("Original parent no longer valid")
	
	drag_ended.emit(self)

func _process(delta):
	if holding and not dragging:
		start_drag()
	
	if dragging:
		# Check if left mouse button is still held
		if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			end_drag()
			holding = false
		else:
			global_position = get_global_mouse_position() - drag_offset
	
	update_debug_label()  # Update every frame while we debug

func _on_mouse_entered():
	modulate = Color(1.2, 1.2, 1.2)
	print("Mouse entered card:", card_data.card_name if card_data else "unknown")

func _on_mouse_exited():
	if not dragging:
		modulate = Color.WHITE
	print("Mouse exited card:", card_data.card_name if card_data else "unknown")

func update_debug_label():
	if debug_label:
		var parent_name = get_parent().name if get_parent() else "NO PARENT"
		debug_label.text = "[%s] Parent: %s" % [name, parent_name]
