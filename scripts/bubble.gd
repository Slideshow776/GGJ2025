class_name Bubble
extends Area2D

@export var _rotation_speed := 3.0

var _player: Player
var _position_tween: Tween


func _ready():
	body_entered.connect(_on_area_entered)


func _process(delta: float) -> void:
	if _player:
		rotation += _rotation_speed * delta    
		_player.rotation = rotation


func enter_player(player: Player) -> void:
	if player.is_dead:
		return
	
	_player = player
	
	_position_tween = create_tween()
	_position_tween.set_trans(Tween.TRANS_SPRING)
	_position_tween.set_ease(Tween.EASE_OUT)
	_position_tween.tween_property(player, "global_position", global_position, 0.25)


func exit_player() -> void:
	_player = null
	_position_tween.stop()
	_pop()


func _on_area_entered(area_that_entered: Node) -> void:
	if area_that_entered is Player:
		var player = area_that_entered
		if player.is_dead:
			return
		
		enter_player(player)
		player.bubble = self
		player.velocity = Vector2.ZERO


func _pop() -> void:
	queue_free()
