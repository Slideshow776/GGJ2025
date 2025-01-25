extends Node2D

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
		print("placing player in bubble")
		first_player_event = false
		temp()
		return
	
	print("moving player")


func temp():
	var bubble = $entities/Bubbles/FirstBubble
	
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(player, "position", bubble.position, 1.0)
	tween.finished.connect(func() -> void:
		bubble.enter_player(player)
	)
