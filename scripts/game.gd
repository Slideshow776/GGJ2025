extends Node2D

@export var shoot_speed = 1000

var first_player_event:= true
var score := 0

@onready var player: Player = %Player
@onready var label: Label = %Label


func _ready() -> void:
	_connect_pickup_signals()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()
	if event is InputEventMouseButton:  # Detect any mouse button
		if event.pressed:
			_move_player()
	elif event is InputEventScreenTouch:  # Detect touch events
		if event.pressed:
			_move_player()


func _move_player() -> void:
	if first_player_event:
		first_player_event = false
		enter_player_in_first_bubble()
		return
	
	shoot_player()


func enter_player_in_first_bubble():
	var bubble = $entities/Bubbles/FirstBubble as Bubble
	player.bubble = bubble
	bubble.enter_player(player)
	
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(player, "position", bubble.position, 1.0)


func shoot_player() -> void:
	if player.bubble == null:
		return
	
	var shoot_direction = Vector2.UP.rotated(player.bubble.rotation)
	player.bubble.exit_player()
	player.bubble = null
	
	var velocity = shoot_direction * shoot_speed
	player.velocity = velocity


func _connect_pickup_signals() -> void:
	var entities = $entities/Pickups  # Adjust this path if `entities` is not a direct child
	if entities:
		for child in entities.get_children():
			if child is Pickup:
				child.picked_up.connect(_on_pickup)
	else:
		print("No pickup nodes found.")


func _on_pickup() -> void:	
	score += 10
	label.set_text("Score: " + str(score))
