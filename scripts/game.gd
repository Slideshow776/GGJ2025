extends Node2D

@export var shoot_speed := 1000
@export var game_over_wait_duration := 1.75

var level_scenes: Array[PackedScene] = []  # Array to store all the level scenes
var loaded_levels: Array[Level2] = []
var num_levels := 0
var level_height := 1280
var is_first_player_event := true
var player_original_position: Vector2
var background_original_position: Vector2
var camera_original_position: Vector2
var is_game_over := false
var first_bubble: Bubble
var camera_counter := 0.0
var camera_frequency := 0.2
var is_camera_counting := false
var first_bubble_move_duration = 1.0
var position_tween: Tween

@onready var player: Player = %Player
@onready var label: Label = %Label
@onready var level_0: Level2 = %Level0  # Reference to the first level (Level0)
@onready var background: Sprite2D = %Background
@onready var camera_2d: Camera2D = %Camera2D


func _ready() -> void:
	_load_levels_from_directory()
	_connect_pickup_signals(level_0)
	level_scenes.append(level_0)
	num_levels += 1
	load_new_level()
	camera_2d.zoom = Vector2.ONE * 0.9
	
	background_original_position = background.position
	camera_original_position = camera_2d.position
	player_original_position = player.global_position
	player.died.connect(_restart)


func _process(delta: float) -> void:
	var latest_level: Level2 = loaded_levels[-1]
	if player.position.y < latest_level.position.y + level_height:
		load_new_level()
		remove_old_level()
	
	if is_camera_counting:
		camera_counter += delta
		
	if !is_game_over and camera_counter >= first_bubble_move_duration * 0.2:
		is_camera_counting = false
		if player.position.y < 2392 and (player.position.x > -170 and player.position.x < 850):
			background.position.y = player.global_position.y
			camera_2d.position.y = player.position.y
		else:
			_restart()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("restart") and get_tree():
		get_tree().reload_current_scene()
	
	if event is InputEventMouseButton:  # Detect any mouse button
		if event.pressed:
			_move_player()
	elif event is InputEventScreenTouch:  # Detect touch events
		if event.pressed:
			_move_player()


func _load_levels_from_directory() -> void:
	var directory_path := "res://scenes/levels"
	var dir = DirAccess.open(directory_path)
	if dir == null:
		print("Error: Could not open directory:", directory_path)
		return

	dir.list_dir_begin()

	while true:
		var file_name = dir.get_next()
		if file_name == "":
			break

		if file_name == "level_0.tscn":
			continue

		var scene_path = directory_path + "/" + file_name

		var file = FileAccess.open(scene_path, FileAccess.READ)
		if file == null:
			print("Error: File not found:", scene_path)
			continue

		var scene = load(scene_path) as PackedScene
		if scene:
			level_scenes.append(scene)
			num_levels += 1
		else:
			print("Error: Failed to load scene:", scene_path)

	dir.list_dir_end()  # End directory iteration
	#print("Loaded levels:", level_scenes.size())


func load_new_level() -> void:
	if level_scenes.size() == 0:
		print("No levels available for loading.")
		return

	var level_scene = level_scenes[randi() % level_scenes.size()]
	var new_level = level_scene.instantiate() as Level2
	
	if new_level == null:
		print("Error: Failed to instantiate new level.")
		return
	
	new_level.set_new_position(Vector2(0.0, -(loaded_levels.size() + 1) * level_height))

	add_child(new_level)
	loaded_levels.append(new_level)
	
	_connect_pickup_signals(new_level)


func remove_old_level() -> void: # a better approach would be to pool the levels...
	if loaded_levels.size() < 4:
		return

	loaded_levels[-4].queue_free()


func _move_player() -> void:
	if is_game_over:
		get_tree().reload_current_scene()
	
	if is_first_player_event:
		is_first_player_event = false
		is_camera_counting = true
		enter_player_in_first_bubble()
		return
	
	shoot_player()


func enter_player_in_first_bubble():
	first_bubble = level_0.first_bubble
	if first_bubble == null:
		print("game.gd => Error: first bubble is null!")
		return
	
	player.bubble = first_bubble
	first_bubble.enter_player(player)
	
	position_tween = create_tween()
	position_tween.set_trans(Tween.TRANS_EXPO)
	position_tween.set_ease(Tween.EASE_OUT)
	position_tween.tween_property(player, "global_position", first_bubble.global_position, first_bubble_move_duration)


func shoot_player() -> void:
	if player.bubble == null:
		return
	
	var shoot_direction = Vector2.UP.rotated(player.bubble.rotation)
	if player.bubble.exit_player():
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
	game_manager.score += 10
	label.set_text("Score: " + str(game_manager.score))


func _restart() -> void:
	is_game_over = true
	await get_tree().create_timer(game_over_wait_duration).timeout
	if get_tree():
		get_tree().reload_current_scene()
