extends CharacterBody2D

@onready var sprite_2d: Sprite2D = %Sprite2D

var original_scale: Vector2


func _ready():
	randomize()  # Ensure randomness each run
	original_scale = sprite_2d.scale * 0.5
	animate_fork()  # Start animation for the fork obstacle


func animate_fork() -> void:
	while true:
		# Ensure the tween is recreated for each loop iteration
		var tween = create_tween()
		
		# Random scale factors for menace
		var target_scale = original_scale * Vector2(randf_range(1.5, 2.5), randf_range(1.5, 2.5))
		var random_duration = randf_range(0.5, 2.0)  # Random duration for scaling
		
		# Animate scaling up
		tween.tween_property(sprite_2d, "scale", target_scale, random_duration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		await tween.finished  # Wait for the tween to finish
		
		# Pause menacingly
		await get_tree().create_timer(randf_range(1.0, 3.0)).timeout
		
		# Recreate tween for the next animation
		tween = create_tween()
		
		# Animate scaling down
		tween.tween_property(sprite_2d, "scale", original_scale, random_duration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
		await tween.finished
		
		# Pause menacingly again
		await get_tree().create_timer(randf_range(1.0, 3.0))
