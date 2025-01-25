class_name Pickup
extends Area2D

signal picked_up


func _ready() -> void:
	body_entered.connect(_on_area_entered)


func _on_area_entered(area_that_entered: Node) -> void:
	if area_that_entered is Player:
		if area_that_entered.is_dead:
			return
		
		picked_up.emit()
		_remove()


func _remove() -> void:
	queue_free()
