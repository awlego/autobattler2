# CardVisual.gd
extends Control
class_name CardVisual 

var card_data: CombatCard
var is_player_card: bool = true

# Node references
var card_bg: ColorRect
var name_label: Label
var attack_label: Label
var health_label: Label
var cost_label: Label
var anim_player: AnimationPlayer

const CARD_WIDTH = 120
const CARD_HEIGHT = 160
const MARGIN = 10

var draggable: bool = false
var ghost_node: Node2D = null

signal drag_started(card: CardVisual)
signal drag_ended(card: CardVisual)

func _ready():
	custom_minimum_size = Vector2(CARD_WIDTH, CARD_HEIGHT)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	# Only construct if it hasn't been constructed yet
	if not has_node("CardBackground"):
		construct_card_visual()
		setup_animations()

func construct_card_visual():
	# Add a Control node to handle input
	var control = Control.new()
	control.set_anchors_preset(Control.PRESET_FULL_RECT)
	control.mouse_filter = Control.MOUSE_FILTER_STOP
	control.gui_input.connect(_on_gui_input)
	control.custom_minimum_size = Vector2(CARD_WIDTH, CARD_HEIGHT)
	control.size = Vector2(CARD_WIDTH, CARD_HEIGHT)
	control.position = Vector2.ZERO
	
	# Make the control node clickable
	control.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	# Debug prints
	print("Creating control node for: ", name)
	print("Control node size: ", control.size)
	print("Control mouse filter: ", control.mouse_filter)
	
	add_child(control)
	
	# Create background
	card_bg = ColorRect.new()
	card_bg.size = Vector2(CARD_WIDTH, CARD_HEIGHT)
	card_bg.color = Color(0.2, 0.2, 0.2, 1)
	card_bg.name = "CardBackground"
	add_child(card_bg)
	
	# Create container for card content
	var content = VBoxContainer.new()
	content.position = Vector2(MARGIN, MARGIN)
	content.size = Vector2(CARD_WIDTH - 2 * MARGIN, CARD_HEIGHT - 2 * MARGIN)
	content.custom_minimum_size = content.size
	content.name = "CardContent"
	add_child(content)
	
	# Cost label (top-right)
	var cost_bg = ColorRect.new()
	cost_bg.color = Color(0.8, 0.8, 0.2, 1)
	cost_bg.size = Vector2(25, 25)
	cost_bg.position = Vector2(CARD_WIDTH - 30, 5)
	cost_bg.name = "CostBackground"
	add_child(cost_bg)
	
	cost_label = Label.new()
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cost_label.size = cost_bg.size
	cost_bg.add_child(cost_label)
	
	# Name label
	name_label = Label.new()
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.custom_minimum_size = Vector2(CARD_WIDTH - 2 * MARGIN, 30)
	content.add_child(name_label)
	name_label.name = "NameLabel"

	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 50)
	content.add_child(spacer)
	spacer.name = "Spacer"

	# Stats container
	var stats_container = HBoxContainer.new()
	stats_container.size_flags_vertical = Control.SIZE_FILL
	content.add_child(stats_container)
	stats_container.name = "StatsContainer"
	
	# Attack stat
	var attack_container = _create_stat_container(Color(0.8, 0.2, 0.2, 1))
	stats_container.add_child(attack_container)
	attack_container.name = "AttackContainer"
	attack_label = attack_container.get_node("StatBackground/StatLabel")
	
	# Add spacer between stats
	var stat_spacer = Control.new()
	stat_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stats_container.add_child(stat_spacer)
	stat_spacer.name = "StatSpacer"
	
	# Health stat
	var health_container = _create_stat_container(Color(0.2, 0.8, 0.2, 1))
	stats_container.add_child(health_container)
	health_container.name = "HealthContainer"
	health_label = health_container.get_node("StatBackground/StatLabel")

	# Add AnimationPlayer
	anim_player = AnimationPlayer.new()
	anim_player.name = "AnimationPlayer"
	add_child(anim_player)

func _create_stat_container(color: Color) -> Control:
	var container = Control.new()
	container.custom_minimum_size = Vector2(30, 30)
	
	var bg = ColorRect.new()
	bg.color = color
	bg.size = Vector2(30, 30)
	bg.name = "StatBackground"
	container.add_child(bg)
	
	var label = Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = bg.size
	label.name = "StatLabel"
	bg.add_child(label)
	
	return container

func setup_animations():
	# Attack animation
	var attack_anim = Animation.new()
	var attack_track = attack_anim.add_track(Animation.TYPE_VALUE)
	attack_anim.track_set_path(attack_track, ":position:y")
	attack_anim.track_insert_key(attack_track, 0.0, 0)
	attack_anim.track_insert_key(attack_track, 0.2, -30)
	attack_anim.track_insert_key(attack_track, 0.4, 0)
	attack_anim.length = 0.4
	
	# Damage animation
	var damage_anim = Animation.new()
	var damage_track = damage_anim.add_track(Animation.TYPE_VALUE)
	damage_anim.track_set_path(damage_track, ".:modulate")
	damage_anim.track_insert_key(damage_track, 0.0, Color(1,1,1,1))
	damage_anim.track_insert_key(damage_track, 0.1, Color(1,0,0,1))
	damage_anim.track_insert_key(damage_track, 0.3, Color(1,1,1,1))
	damage_anim.length = 0.3
	
	# Death animation
	var death_anim = Animation.new()
	var death_track = death_anim.add_track(Animation.TYPE_VALUE)
	death_anim.track_set_path(death_track, ".:modulate:a")
	death_anim.track_insert_key(death_track, 0.0, 1.0)
	death_anim.track_insert_key(death_track, 0.5, 0.0)
	death_anim.length = 0.5
	
	# Create and add animation library
	var lib = AnimationLibrary.new()
	lib.add_animation("attack", attack_anim)
	lib.add_animation("take_damage", damage_anim)
	lib.add_animation("death", death_anim)
	anim_player.add_animation_library("", lib)  # Empty string for default library

func setup_card(new_card: CombatCard, is_player: bool = true):
	card_data = new_card
	is_player_card = is_player
	
	# If the node isn't ready yet, defer the update
	if not is_inside_tree():
		# Call construct_card_visual immediately instead of waiting for _ready
		construct_card_visual()
		setup_animations()
	
	print("Setting up card: ", new_card.card_name, " draggable: ", draggable)
	update_display()

func update_display():
	if card_data:
		name_label.text = card_data.card_name
		attack_label.text = str(card_data.attack)
		health_label.text = str(card_data.health)
		cost_label.text = str(card_data.cost)

func play_attack_animation():
	anim_player.play("attack")

func play_damage_animation():
	anim_player.play("take_damage")

func play_death_animation():
	anim_player.play("death")

func _to_string() -> String:
	return "CombatCardVisual"

func set_draggable(can_drag: bool):
	draggable = can_drag

func get_drag_data(_position: Vector2):
	if not draggable:
		return null
	
	# Create preview
	var preview = Control.new()
	var preview_card = duplicate()
	preview_card.modulate.a = 0.7
	preview.add_child(preview_card)
	
	# Create ghost card in original position
	# create_ghost()
	
	set_drag_preview(preview)
	emit_signal("drag_started", self)
	return self

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_DRAG_END:
			remove_ghost()
			emit_signal("drag_ended", self, position)

func create_ghost():
	ghost_node = duplicate()
	ghost_node.modulate.a = 0.5
	get_parent().add_child(ghost_node)

func remove_ghost():
	if ghost_node:
		ghost_node.queue_free()
		ghost_node = null

func move_to_position_with_scale(new_position: Vector2, new_scale: Vector2, duration: float = 0.3):
	var tween = create_tween()
	tween.set_parallel(true)  # Allows multiple properties to animate simultaneously
	tween.tween_property(self, "position", new_position, duration)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", new_scale, duration)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)

func scale_card(new_scale: float, duration: float = 0.3):
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(new_scale, new_scale), duration)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				print("Card clicked: ", card_data.card_name if card_data else "No card data")
				# You can add more click handling logic here
