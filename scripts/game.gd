extends Node2D

@export var shoot_speed = 1000

var first_player_event:= true

@onready var player: Player = %Player


func _input(event: InputEvent) -> void:
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
		print("player.bubble is null")
		return
	
	var shoot_direction = Vector2.UP.rotated(player.bubble.rotation)
	player.bubble.exit_player()
	player.bubble = null
	
	var velocity = shoot_direction * shoot_speed
	player.velocity = velocity
