extends CharacterBody2D

var player_id: int
var hp: int = 100
var speed: float = 200.0
var selected_spell: int = 1

func setup(id: int) -> void:
	player_id = id
	add_to_group("players")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1: selected_spell = 1
			KEY_2: selected_spell = 2
			KEY_3: selected_spell = 3
			KEY_SPACE: cast_spell()

func cast_spell() -> void:
	match selected_spell:
		1: _cast_spell_1()
		2: _cast_spell_2()
		3: _cast_spell_3()

func _cast_spell_1() -> void:
	pass
	
func _cast_spell_2() -> void:
	pass
	
func _cast_spell_3() -> void:
	pass

func _physics_process(delta: float) -> void:
	if multiplayer.is_local_peer(player_id):
		var dir := Vector2.ZERO
		if Input.is_action_pressed("move_up"):
			dir.y -= 1
		if Input.is_action_pressed("move_down"):
			dir.y += 1
		if Input.is_action_pressed("move_left"):
			dir.x -= 1
		if Input.is_action_pressed("move_right"):
			dir.x += 1
		velocity = dir.normalized() * speed
		move_and_slide()

		# Синхронизируем позицию (если надо)
		multiplayer.rpc_unreliable("sync_position", global_position)

@rpc("unreliable")
func sync_position(pos: Vector2) -> void:
	if not multiplayer.is_local_peer(player_id):
		global_position = pos

func _on_hit(damage: int) -> void:
	hp -= damage
	if hp <= 0:
		die()

func die() -> void:
	queue_free()
