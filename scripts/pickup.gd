class_name Pickup
extends Area2D

signal picked_up

@onready var sprite_2d: Sprite2D = %Sprite2D


func _ready() -> void:
	body_entered.connect(_on_area_entered)
	
	rotation = randf_range(-0.5, 0.5)
	
	var tween := create_tween()
	tween.set_loops(-1)  # Set the tween to loop infinitely
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sprite_2d, "rotation", 0.5, 1.4)
	tween.tween_property(sprite_2d, "rotation", -0.5, 1.4)


func _on_area_entered(area_that_entered: Node) -> void:
	if area_that_entered is Player:
		if area_that_entered.is_dead:
			return
		
		picked_up.emit()
		_remove()


func _remove() -> void:
	queue_free()
