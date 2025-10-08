class_name SpellInstance
extends Area2D

@export var speed: float = 400.0
@export var direction: Vector2 = Vector2.RIGHT
@export var piercing: bool = false
@export var lifetime: float = 1.0

func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	position += direction.normalized() * speed * delta

func _on_body_entered(body: Node) -> void:
	if not multiplayer.is_server():
		return
	if body.is_in_group("enemies"):
		if not piercing:
			queue_free()

func _process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
