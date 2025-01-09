class_name HexCardView
extends CardView

# Hex-specific constants
const HEX_WIDTH = 140  # Width of the hex
const HEX_HEIGHT = 160  # Height of the hex
var HEX_POINTS = PackedVector2Array([
	Vector2(HEX_WIDTH * 0.25, 0),              # Top
	Vector2(HEX_WIDTH * 0.75, 0),              # Top right
	Vector2(HEX_WIDTH, HEX_HEIGHT * 0.5),      # Bottom right
	Vector2(HEX_WIDTH * 0.75, HEX_HEIGHT),     # Bottom
	Vector2(HEX_WIDTH * 0.25, HEX_HEIGHT),     # Bottom left
	Vector2(0, HEX_HEIGHT * 0.5)               # Top left
])

func _ready():
	super._ready()
	custom_minimum_size = Vector2(HEX_WIDTH, HEX_HEIGHT)
	size = custom_minimum_size

func construct_visual():
	# Background (hex polygon)
	var background = Polygon2D.new()
	background.polygon = HEX_POINTS
	background.color = Color(0.3, 0.3, 0.3, 1.0)
	add_child(background)
	
	# Add border
	var border = Line2D.new()
	border.points = Array(HEX_POINTS) + [HEX_POINTS[0]]
	border.width = 2
	border.default_color = Color(0.4, 0.4, 0.4, 1.0)
	add_child(border)
	
	# Art placeholder (hex polygon)
	var art_placeholder = Polygon2D.new()
	var art_margin = 15
	var art_points = PackedVector2Array([
		Vector2(HEX_WIDTH * 0.25 + art_margin, art_margin),
		Vector2(HEX_WIDTH * 0.75 - art_margin, art_margin),
		Vector2(HEX_WIDTH - art_margin, HEX_HEIGHT * 0.4),
		Vector2(HEX_WIDTH * 0.75 - art_margin, HEX_HEIGHT * 0.6),
		Vector2(HEX_WIDTH * 0.25 + art_margin, HEX_HEIGHT * 0.6),
		Vector2(art_margin, HEX_HEIGHT * 0.4)
	])
	art_placeholder.polygon = art_points
	art_placeholder.color = Color(randf(), randf(), randf(), 1.0)
	add_child(art_placeholder)
	
	# Create labels
	name_label = Label.new()
	attack_label = Label.new()
	health_label = Label.new()
	cost_label = Label.new()
	
	# Setup the labels and stats
	_setup_labels_and_stats()

func _setup_labels_and_stats():
	# Name label in center
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.size = Vector2(size.x, 30)
	name_label.position = Vector2(0, size.y * 0.6 + 5)
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(name_label)
	
	# Stats boxes with backgrounds
	_setup_stat_box(cost_label, Vector2(5, 5), Color(0.2, 0.6, 0.8))  # Cost (blue)
	_setup_stat_box(attack_label, Vector2(5, size.y - 35), Color(0.8, 0.2, 0.2))  # Attack (red)
	_setup_stat_box(health_label, Vector2(size.x - 35, size.y - 35), Color(0.2, 0.8, 0.2))  # Health (green)

func _setup_stat_box(label: Label, position: Vector2, color: Color):
	var box = ColorRect.new()
	box.color = color
	box.size = Vector2(30, 30)
	box.position = position
	add_child(box)
	
	# Configure the existing label instead of creating a new one
	label.add_theme_color_override("font_color", Color.WHITE)
	label.text = "0"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = box.size
	label.position = box.position
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	
