extends Node

@export var port: int = 7777
@export var max_players: int = 4

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func start_server() -> void:
	var peer := ENetMultiplayerPeer.new()
	var err = peer.create_server(port, max_players)
	if err != OK:
		push_error("Failed to start ENet server: %s" % err)
		return
		
	var scene_mp := SceneMultiplayer.new()
	get_tree().set_multiplayer(scene_mp, self.get_path())
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	print("Server started on port %d" % port)

func connect_to_server(ip: String) -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	var scene_mp := SceneMultiplayer.new()
	get_tree().set_multiplayer(scene_mp, self.get_path())
	multiplayer.multiplayer_peer = peer
	print("Connecting to server %s:%d" % [ip, port])

func _on_peer_connected(id: int) -> void:
	print("Peer connected: ", id)
	if multiplayer.is_server():
		rpc_id(id, "spawn_player", id)

func _on_peer_disconnected(id: int) -> void:
	print("Peer disconnected: ", id)

@rpc("any_peer")
func spawn_player(id: int) -> void:
	var player_scene := preload("res://Player/Player.tscn")
	var player = player_scene.instantiate()
	player.name = "Player_%d" % id
	get_tree().current_scene.add_child(player)
	player.setup(id)
