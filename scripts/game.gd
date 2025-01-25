extends Node2D

@export var shoot_speed = 1000

var level_scenes: Array[PackedScene] = []  # Array to store all the level scenes
var level_height := 1152
var first_player_event := true
var score := 0

@onready var player: Player = %Player
@onready var label: Label = %Label
@onready var level_0: Node2D = %Level0  # Reference to the first level (Level0)


func _ready() -> void:
	_load_levels_from_directory()
	_connect_pickup_signals(level_0)
	level_scenes.append(level_0)
	load_new_level()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
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
		else:
			print("Error: Failed to load scene:", scene_path)

	dir.list_dir_end()  # End directory iteration
	print("Loaded levels:", level_scenes.size())


func load_new_level() -> void:
	if level_scenes.size() == 0:
		print("No levels available for loading.")
		return

	var level_scene = level_scenes[randi() % level_scenes.size()]
	var new_level = level_scene.instantiate() as Level2
	
	if new_level == null:
		print("Error: Failed to instantiate new level.")
		return	
	
	new_level.set_new_position(Vector2(0.0, -(level_scenes.size() - 1) * level_height))

	add_child(new_level)
	
	_connect_pickup_signals(new_level)


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
