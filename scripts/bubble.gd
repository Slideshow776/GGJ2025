class_name Bubble
extends Area2D

@export var _rotation_speed := 3.0

var _player: Player


func _ready():
	body_entered.connect(_on_area_entered)


func _process(delta: float) -> void:
	if _player:
		rotation += _rotation_speed * delta    
		_player.rotation = rotation


func enter_player(player: Player) -> void:
	_player = player
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SPRING)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(player, "position", position, 0.25)


func exit_player() -> void:
	_player = null


func _on_area_entered(area_that_entered: Node) -> void:
	if area_that_entered is Player:
		print("Player entered the bubble!")
		var player = area_that_entered
		
		enter_player(player)
		player.bubble = self
		player.velocity = Vector2.ZERO
