class_name Level2
extends Node2D


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
