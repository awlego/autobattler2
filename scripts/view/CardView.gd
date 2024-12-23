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

func _ready():
	custom_minimum_size = Vector2(CARD_WIDTH, CARD_HEIGHT)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_STOP
	print("CardView ready - mouse_filter:", mouse_filter)
	construct_visual()
	update_display()  # Initial update

func construct_visual():
	# Background
	var background = ColorRect.new()
	background.color = Color(0.2, 0.2, 0.2, 1)
	background.size = size
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Let input pass to card
	add_child(background)
	
	# Add hover effect
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	# Layout container
	var container = VBoxContainer.new()
	container.size = size
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Let input pass to card
	add_child(container)
	
	# Name
	name_label = Label.new()
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.text = "Unknown"
	container.add_child(name_label)
	
	# Stats container
	var stats = HBoxContainer.new()
	container.add_child(stats)
	
	# Attack
	attack_label = Label.new()
	attack_label.text = "0"
	stats.add_child(attack_label)
	
	# Add spacer
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stats.add_child(spacer)
	
	# Health
	health_label = Label.new()
	health_label.text = "0"
	stats.add_child(health_label)
	
	# Cost (top-left corner)
	cost_label = Label.new()
	cost_label.text = "0"
	cost_label.position = Vector2(5, 5)
	add_child(cost_label)

func update_display():
	if card_data:
		name_label.text = card_data.card_name
		attack_label.text = str(card_data.attack)
		health_label.text = str(card_data.health)
		cost_label.text = str(card_data.cost)

func _gui_input(event: InputEvent):
	print("Card received input:", event)  # Debug print
	if not draggable:
		return
		
	if event is InputEventMouseButton:
		print("Card received mouse button:", event.button_index, " pressed:", event.pressed)
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				print("Card drag started:", card_data.card_name if card_data else "unknown")
				start_drag()
			else:
				print("Card drag ended")
				end_drag()
			get_viewport().set_input_as_handled()

func start_drag():
	dragging = true
	drag_offset = get_local_mouse_position()
	original_parent = get_parent()
	
	# Reparent to viewport for unrestricted movement
	var global_pos = global_position
	original_parent.remove_child(self)
	get_viewport().add_child(self)
	global_position = global_pos
	
	# Visual feedback
	modulate = Color(1.2, 1.2, 1.2)  # Brighten the card
	
	add_to_group("dragged_cards")
	drag_started.emit(self)

func end_drag():
	dragging = false
	modulate = Color.WHITE  # Reset brightness
	
	# If not picked up by a slot, return to original parent
	if is_instance_valid(original_parent):
		var global_pos = global_position
		get_parent().remove_child(self)
		original_parent.add_child(self)
		global_position = global_pos
	
	remove_from_group("dragged_cards")
	drag_ended.emit(self)

func _process(_delta):
	if dragging:
		global_position = get_global_mouse_position() - drag_offset

func _on_mouse_entered():
	modulate = Color(1.2, 1.2, 1.2)
	print("Mouse entered card:", card_data.card_name if card_data else "unknown")

func _on_mouse_exited():
	if not dragging:
		modulate = Color.WHITE
	print("Mouse exited card:", card_data.card_name if card_data else "unknown")
