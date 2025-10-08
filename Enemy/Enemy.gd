extends CharacterBody2D

var speed: float = 50.0
var hp: int = 50

@export var right: bool = true

func _process(_delta: float) -> void:
	if right:
		$AnimatedSprite2D.play("walk_right")
	else:
		$AnimatedSprite2D.play("walk_left")

func _physics_process(_delta: float) -> void:
	var players := get_tree().get_nodes_in_group("players")
	if players.is_empty():
		return

	var nearest := players[0]
	var min_dist := global_position.distance_to(nearest.global_position)

	for p in players:
		var dist := global_position.distance_to(p.global_position)
		if dist < min_dist:
			nearest = p
			min_dist = dist

	var direction: Vector2 = (nearest.global_position - global_position).normalized()
	velocity = direction * speed

	if velocity.x != 0:
		right = velocity.x > 0

	move_and_slide()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("players"):
		body.call("_on_hit", 10)
		queue_free()
