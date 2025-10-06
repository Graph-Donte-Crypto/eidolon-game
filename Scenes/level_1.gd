extends Node

const SPAWN_RANDOM := 5.0


var enemy_spawn_timer := Timer.new()
const ENEMY_SPAWN_RATE := 3.0 # Seconds between enemy spawns
const ENEMY_SPAWN_DISTANCE := 10.0

func _ready():
	# We only need to spawn players on the server.
	if not multiplayer.is_server():
		return

	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)

	# Spawn already connected players.
	for id in multiplayer.get_peers():
		add_player(id)

	# Spawn the local player unless this is a dedicated server export.
	if not OS.has_feature("dedicated_server"):
		add_player(1)

	# Initialize and start the enemy spawn timer
	enemy_spawn_timer.autostart = true
	enemy_spawn_timer.one_shot = false
	enemy_spawn_timer.wait_time = ENEMY_SPAWN_RATE
	enemy_spawn_timer.timeout.connect(spawn_enemy_near_player)
	add_child(enemy_spawn_timer)
	enemy_spawn_timer.start()


func _exit_tree():
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(del_player)
	if is_instance_valid(enemy_spawn_timer):
		enemy_spawn_timer.stop()
		enemy_spawn_timer.queue_free()


func add_player(id: int):
	var character = preload("res://Player/Player.tscn").instantiate()
	# Set player id.
	character.player = id
	character.position = Vector2(SPAWN_RANDOM * (randf() - 0.5), SPAWN_RANDOM * (randf() - 0.5))
	character.name = str(id)
	$Players.add_child(character, true)


func del_player(id: int):
	if not $Players.has_node(str(id)):
		return
	$Players.get_node(str(id)).queue_free()

func spawn_enemy_near_player():
	if not multiplayer.is_server():
		return # Only the server handles spawning

	var players = $Players.get_children()
	if players.is_empty():
		return # Cannot spawn if no players exist

	# 1. Pick a random player
	var target_player = players[randi() % players.size()]
	var player_position = target_player.position

	# 2. Calculate a random position around the player
	# Get a random angle (0 to 2*PI)
	var random_angle = randf() * 2.0 * PI
	# Calculate an offset vector based on the angle and spawn distance
	var offset_vector = Vector2(
		cos(random_angle) * ENEMY_SPAWN_DISTANCE,
		sin(random_angle) * ENEMY_SPAWN_DISTANCE
	)

	# The spawn position is the player's position plus the offset
	var spawn_position = player_position + offset_vector

	# 3. Instantiate and configure the enemy
	var enemy = preload("res://Enemy/Enemy.tscn").instantiate()
	enemy.position = spawn_position

	# 4. Use the MultiplayerSpawner to spawn the enemy for all clients
	# Assuming $EnemySpawner is your MultiplayerSpawner
	$Enemies.add_child(enemy)
