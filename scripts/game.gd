extends Node2D

@export var shoot_speed = 1000

var level_scenes: Array[PackedScene] = []  # Array to store all the level scenes
var active_levels: Array[Node2D] = []  # Array to store active level nodes
var level_height := 1152  # Adjust to match the vertical size of your levels
var first_player_event := true
var score := 0

@onready var player: Player = %Player
@onready var label: Label = %Label


func _ready() -> void:
	_load_levels_from_directory()  # Load levels from folder
	load_new_level()  # Load the first level
	#load_new_level()  # Load a second level to start


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()
	if event is InputEventMouseButton:  # Detect any mouse button
		if event.pressed:
			_move_player()
	elif event is InputEventScreenTouch:  # Detect touch events
		if event.pressed:
			_move_player()


func _physics_process(delta: float) -> void:
	_remove_offscreen_levels()

	if active_levels.size() > 0:
		var top_level = active_levels[active_levels.size() - 1]
		if top_level.global_position.y + level_height < player.global_position.y:
			load_new_level()


func _load_levels_from_directory() -> void:
	var directory_path := "res://scenes/levels"
	var dir = DirAccess.open(directory_path)
	if dir == null:
		print("Error: Could not open directory:", directory_path)
		return

	dir.list_dir_begin()  # Begin iterating through the directory

	while true:
		var file_name = dir.get_next()
		if file_name == "":
			break  # Stop if no more files are found

		print("Checking file: ", file_name)  # Debug: Print the name of each file

		if file_name.ends_with(".tscn") and file_name != "level_0.tscn":
			var scene_path = directory_path + "/" + file_name
			print("Trying to load scene from path:", scene_path)  # Debug: Show the full scene path

			# Verify if the scene file exists before loading
			var file = FileAccess.open(scene_path, FileAccess.READ)
			if file == null:
				print("Error: File not found:", scene_path)
				continue

			var scene = load(scene_path) as PackedScene
			if scene:
				print("Successfully loaded scene:", file_name)  # Debug: Successful loading
				level_scenes.append(scene)
			else:
				print("Error: Failed to load scene:", scene_path)

	dir.list_dir_end()  # End directory iteration
	print("Loaded levels:", level_scenes.size())


func load_new_level() -> void:
	if level_scenes.size() == 0:
		print("No levels available for loading.")
		return

	var level_scene = level_scenes[randi() % level_scenes.size()]  # Pick a random level
	var new_level = level_scene.instantiate() as Node2D
	
	# Stack new level above the last active level (moving up)
	if active_levels.size() == 0:
		# First level at the bottom (positioned at the origin)
		new_level.position = Vector2(0, 0)
	else:
		# Get the last level's position and place the new level above it
		var last_level = active_levels[active_levels.size() - 1]
		# Position the new level above the last one (Y value decreases as we go up)
		new_level.position = Vector2(0, last_level.position.y + level_height)

	# Move all children of the new level to align with the level's new position
	for child in new_level.get_children():
		print("mark 0")
		if child is Node2D:
			print("mark 1")
			child.position += new_level.position

	# Add the new level to the scene
	add_child(new_level)

	# Track the new level in the active_levels array
	active_levels.append(new_level)
	
	print("added level: " + new_level.name)

	# Connect pickups in the new level
	_connect_pickup_signals(new_level)



# Remove levels that are off-screen, below the player
func _remove_offscreen_levels() -> void:
	for level in active_levels:
		if level.global_position.y > player.global_position.y + level_height:
			print("Removing level:", level.name)
			active_levels.erase(level)  # Remove the level from the active array
			level.queue_free()  # Free the level from the scene


func _move_player() -> void:
	if first_player_event:
		first_player_event = false
		enter_player_in_first_bubble()
		return
	
	shoot_player()


func enter_player_in_first_bubble():
	var bubble = %Level0/Entities/Bubbles/FirstBubble as Bubble
	if bubble == null:
		print("game.gd => Error: first bubble is null!")
		return
		
	player.bubble = bubble
	bubble.enter_player(player)
	
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(player, "global_position", bubble.global_position, 1.0)


func shoot_player() -> void:
	if player.bubble == null:
		return
	
	var shoot_direction = Vector2.UP.rotated(player.bubble.rotation)
	player.bubble.exit_player()
	player.bubble = null
	
	var velocity = shoot_direction * shoot_speed
	player.velocity = velocity


func _connect_pickup_signals(level: Node2D) -> void:
	var pickups = level.get_node("Entities/Pickups") if level.has_node("Entities/Pickups") else null
	if pickups:
		for child in pickups.get_children():
			if child is Pickup:
				child.picked_up.connect(_on_pickup)


func _on_pickup() -> void:    
	score += 10
	label.set_text("Score: " + str(score))
