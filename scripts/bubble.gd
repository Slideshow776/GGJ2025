class_name Bubble
extends Node2D

@export var _rotation_speed := 2.0

var _player: Player


func _process(delta: float) -> void:
	if _player:
		rotation += _rotation_speed * delta    
		_player.rotation = rotation


func enter_player(player) -> void:
	_player = player


func exit_player() -> void:
	_player = null
