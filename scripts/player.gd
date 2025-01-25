class_name Player
extends CharacterBody2D

var bubble: Bubble


func _physics_process(delta):
	move_and_slide()
