class_name Player
extends CharacterBody2D

signal died

@export var death_velocity := 0.5
@export var death_rotation_min := PI / 128
@export var death_rotation_max := PI / 64

var bubble: Bubble
var is_dead := false
var _death_rotation := 0.0
var original_scale: Vector2

@onready var camera_2d: Camera2D = %Camera2D
@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var gpu_particles_2d: GPUParticles2D = %GPUParticles2D


func _ready() -> void:
	original_scale = sprite_2d.scale
	gpu_particles_2d.local_coords = false


func _physics_process(delta) -> void:
	move_and_slide()
	if is_dead:
		rotation += _death_rotation


func die() -> void:
	velocity *= -death_velocity
	_death_rotation = randf_range(death_rotation_min, death_rotation_max)
	is_dead = true
	died.emit()
	normal_animation()
	
	%FartSound.pitch_scale = randf_range(0.5, 1.5)
	%FartSound.play()
	
	
func air_animation() -> void:
	gpu_particles_2d.emitting = true
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite_2d, "scale", original_scale * Vector2(0.5, 1.5), 0.5)
		
	
func normal_animation() -> void:
	gpu_particles_2d.emitting = false
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite_2d, "scale", original_scale, 0.5)
	
	
func restart() -> void:
	velocity = Vector2.ZERO
	rotation = 0.0
	bubble = null
	is_dead = false
	_death_rotation = 0.0
