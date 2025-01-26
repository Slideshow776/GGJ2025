class_name Player
extends CharacterBody2D

signal died

@export var death_velocity := 0.5
@export var death_rotation_min := PI / 128
@export var death_rotation_max := PI / 64

var bubble: Bubble
var is_dead := false
var _death_rotation := 0.0

@onready var camera_2d: Camera2D = %Camera2D


func _physics_process(delta) -> void:
	move_and_slide()
	if is_dead:
		rotation += _death_rotation


func die() -> void:
	velocity *= -death_velocity
	_death_rotation = randf_range(death_rotation_min, death_rotation_max)
	is_dead = true
	died.emit()
	
	%FartSound.pitch_scale = randf_range(0.5, 1.5)
	%FartSound.play()
	
func restart() -> void:
	velocity = Vector2.ZERO
	rotation = 0.0
	bubble = null
	is_dead = false
	_death_rotation = 0.0
