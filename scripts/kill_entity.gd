class_name KillEntity
extends Area2D


func _ready():
	body_entered.connect(_on_area_entered)


func _on_area_entered(area_that_entered: Node) -> void:
	if area_that_entered is Player:
		area_that_entered.die()
