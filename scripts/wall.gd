extends CharacterBody2D

var original_scale: Vector2

@onready var sprite_2d: Sprite2D = %Sprite2D

func _ready() -> void:
	# Store the original scale for reference
	original_scale = sprite_2d.scale
	animate_wall()  # Start the licking animation

func animate_wall() -> void:
	while true:
		# Create a tween and add it to the scene tree
		var tween = create_tween()

		# Lick out (scale up or stretch)
		var target_scale = original_scale * Vector2(1.0, 1.1)  # Stretch vertically
		tween.tween_property(sprite_2d, "scale", target_scale, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		await tween.finished  # Wait for the tween to finish

		# Lick back (return to original scale)
		tween = create_tween()  # Create a new tween for the next animation
		tween.tween_property(sprite_2d, "scale", original_scale, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		await tween.finished

		# Pause between licks to look creepy
		await get_tree().create_timer(randf_range(0.9, 1.1)).timeout
