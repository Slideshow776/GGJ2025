class_name Bubble
extends Area2D

@export var _rotation_speed := randf_range(2.0, 4.0)
@export var bubble_normal_texture: Texture
@export var bubble_arrow_texture: Texture
@export var bubble_pop_texture: Texture

var _player: Player
var _position_tween: Tween
var _current_texture: Texture
var original_scale: Vector2
var is_clockwise := randi() % 2 == 0

@onready var sprite_2d: Sprite2D = %Sprite2D


func _ready():
	body_entered.connect(_on_area_entered)
	rotation = randf_range(0.0, 2.0 * PI)
	
	sprite_2d.texture = bubble_normal_texture
	_current_texture = bubble_normal_texture
	original_scale = sprite_2d.scale
	scale = original_scale * randf_range(4.0, 12.0)


func _process(delta: float) -> void:
	if _player:
		if is_clockwise:
			rotation += _rotation_speed * delta    
		else:
			rotation -= _rotation_speed * delta    
		_player.rotation = rotation


func enter_player(player: Player) -> void:
	if player.is_dead:
		return
	
	_player = player
	_player.normal_animation()
	
	sprite_2d.texture = bubble_arrow_texture
	_current_texture = bubble_arrow_texture
	
	var tween := create_tween()
	tween.tween_property(sprite_2d, "scale", original_scale * Vector2(1.4, 1.4), 0.25)
	tween.tween_property(sprite_2d, "scale", original_scale * Vector2(1, 1), 0.25)
	
	_position_tween = create_tween()
	_position_tween.set_trans(Tween.TRANS_BOUNCE)
	_position_tween.set_ease(Tween.EASE_OUT)
	_position_tween.tween_property(player, "global_position", global_position, 0.25)
	_position_tween.finished.connect(func() -> void: player.bubble = self)


func exit_player() -> bool:
	if _position_tween.is_running():
		return false
		
	_player.air_animation()
	_player = null
	_position_tween.stop()
	_pop()
	return true


func _on_area_entered(area_that_entered: Node) -> void:
	if area_that_entered is Player:
		var player = area_that_entered
		if player.is_dead:
			return
		
		enter_player(player)
		player.velocity = Vector2.ZERO


func _pop() -> void:
	sprite_2d.texture = bubble_pop_texture
	_current_texture = bubble_pop_texture
	var tween := create_tween()
	tween.tween_property(sprite_2d, "scale", original_scale * Vector2(2.4, 2.4), 0.4)
	
	# Create a timer to wait before calling queue_free()
	var timer = Timer.new()
	add_child(timer)  # Add the timer as a child to the current node
	timer.wait_time = .4  # Set the timer to 0.2 seconds
	timer.one_shot = true  # Ensure it only triggers once
	timer.start()  # Start the timer
	
	# Wait for the timer to finish
	await timer.timeout  # Wait for the timer's timeout signal
	
	# Now free the bubble
	queue_free()
