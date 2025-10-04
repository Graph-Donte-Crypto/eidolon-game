extends CharacterBody2D

const SPEED = 300.0


func _draw() -> void:
	draw_circle(Vector2.ZERO, 10, Color.RED)

func _physics_process(_delta: float) -> void:
	var input_vec = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	).normalized()

	if input_vec != Vector2.ZERO:
		self.velocity = input_vec * SPEED
	else:
		self.velocity = self.velocity.move_toward(Vector2.ZERO, SPEED)

	move_and_slide()
