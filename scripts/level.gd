class_name Level2
extends Node2D

@export var bubble_scene: PackedScene  # Assign your Bubble scene here in the editor

# Store references to the original bubbles
var original_bubbles: Array[Bubble] = []
var first_bubble: Bubble


func _ready() -> void:
	_store_original_bubbles()


func _store_original_bubbles() -> void:
	# Capture all original bubbles for recreation
	var bubbles_node = get_node_or_null("Entities/Bubbles")
	if not bubbles_node:
		return

	original_bubbles.clear()
	var bottommost_bubble: Bubble = null

	for child in bubbles_node.get_children():
		if child is Bubble:
			original_bubbles.append(child.duplicate())  # Duplicate the bubble node

			# Check for the bottommost bubble
			if bottommost_bubble == null or child.position.y > bottommost_bubble.position.y:
				bottommost_bubble = child

	first_bubble = bottommost_bubble


func restart() -> void:
	# Reset all bubbles in the level using the stored originals
	var bubbles_node = get_node_or_null("Entities/Bubbles")
	if not bubbles_node:
		return

	# Remove all existing bubbles
	for child in bubbles_node.get_children():
		if child is Bubble:
			(child as Bubble)._player = null
			child.queue_free()

	# Recreate bubbles from the stored originals
	var bottommost_bubble: Bubble = null
	for bubble in original_bubbles:
		var new_bubble = bubble_scene.instantiate() as Bubble
		if new_bubble:
			new_bubble.position = bubble.position
			new_bubble.rotation = bubble.rotation
			bubbles_node.add_child(new_bubble)

			# Check for the bottommost bubble
			if bottommost_bubble == null or new_bubble.position.y > bottommost_bubble.position.y:
				bottommost_bubble = new_bubble

	first_bubble = bottommost_bubble
	first_bubble._player = null


func set_new_position(new_position: Vector2):
	position += new_position	
	get_child(0).position += new_position
	
	var bubbles_node = get_node_or_null("Entities/Bubbles")
	if bubbles_node:
		for node in bubbles_node.get_children():
			if node is Node2D:
				node.position += new_position
				
	var enemies_node = get_node_or_null("Entities/Enemies")
	if enemies_node:
		for node in enemies_node.get_children():
			if node is Node2D:
				node.position += new_position
				
	var pickups_node = get_node_or_null("Entities/Pickups")
	if pickups_node:
		for node in pickups_node.get_children():
			if node is Node2D:
				node.position += new_position
				
	var obstacles_node = get_node_or_null("Entities/Obstacles")
	if obstacles_node:
		for node in obstacles_node.get_children():
			if node is Node2D:
				node.position += new_position
				
	var walls_node = get_node_or_null("Entities/Walls")
	if walls_node:
		for node in walls_node.get_children():
			if node is Node2D:
				node.position += new_position
