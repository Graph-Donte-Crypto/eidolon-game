extends CharacterBody2D

const SPEED = 300.0

func _draw() -> void:
	draw_circle(Vector2.ZERO, 10, Color.RED)

func _physics_process(delta: float) -> void:
	# Get the input dx and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var dy := Input.get_axis("ui_up", "ui_down")
	if dy:
		velocity.y = dy * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	var dx := Input.get_axis("ui_left", "ui_right")
	if dx:
		velocity.x = dx * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
