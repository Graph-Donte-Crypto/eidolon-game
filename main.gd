extends Node

const PORT = 4433

enum GameType {None, Client, Server}

var type: GameType = GameType.None:
	set(new_type):
		type = new_type
		game_type_changed.emit(type)

signal game_type_changed(new_type: GameType)

func _ready():
	# Start paused.
	# get_tree().paused = true
	# You can save bandwidth by disabling server relay and peer notifications.
	multiplayer.server_relay = false

	# Automatically start the server in headless mode.
	if DisplayServer.get_name() == "headless":
		print("Automatically starting dedicated server.")
		_on_host_pressed.call_deferred()
	else:
		var window = get_window()
		window.size = Vector2(800, 600)


func _on_host_pressed():
	# Start as server.
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server.")
		return
	multiplayer.multiplayer_peer = peer
	type = GameType.Server
	start_game()


func _on_connect_pressed():
	# Start as client.
	var txt : String = $UI/StartGame/Connect/Options/Remote.text
	if txt == "":
		OS.alert("Need a remote to connect to.")
		return
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(txt, PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer client.")
		return
	multiplayer.multiplayer_peer = peer
	multiplayer.server_disconnected.connect(on_disconnection)
	type = GameType.Client
	start_game()

func on_disconnection():
	type = GameType.None
	$UI/Main.show()
	$UI/InGame.hide()
	var peer = multiplayer.multiplayer_peer;
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	peer.close()
	multiplayer.server_disconnected.disconnect(on_disconnection)

func start_game():
	# Hide the UI and unpause to start the game.
	$UI/StartGame.hide()
	if multiplayer.is_server():
		change_level(load("res://Scenes/Level1.tscn")) #call_deferred
	
func clear_current_level():
	var level = $Level
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	
# Call this function deferred and only on the main authority (server).
func change_level(scene: PackedScene):
	# Remove old level if any.
	clear_current_level()
	# Add new level.
	$Level.add_child(scene.instantiate())

# The server can restart the level by pressing Home.
func _input(event):
	if event.is_action("ui_cancel") and Input.is_action_just_pressed("ui_cancel"):
		var mig = $UI/InGame
		mig.visible = not mig.visible
	
	if not multiplayer.is_server():
		return
	if event.is_action("ui_home") and Input.is_action_just_pressed("ui_home"):
		change_level(load("res://Scenes/Level1.tscn")) #call_deferred


func _on_button_play_pressed() -> void:
	$UI/Main.hide()
	$UI/StartGame.show()


func _on_button_exit_pressed() -> void:
	get_tree().quit()


func _on_button_back_pressed() -> void:
	$UI/StartGame.hide()
	$UI/Main.show()


func _on_button_close_pressed() -> void:
	$UI/InGame.hide()

func _on_game_type_changed(new_type: GameType) -> void:
	match new_type:
		GameType.None:
			pass
		GameType.Client:
			$UI/InGame/Control/Info/Client.show()
			$UI/InGame/Control/Info/Server.hide()
		GameType.Server:
			$UI/InGame/Control/Info/Client.hide()
			$UI/InGame/Control/Info/Server.show()
			


func _on_button_stop_server_pressed() -> void:
	if not multiplayer.is_server():
		return
	# multiplayer.multiplayer_peer.close()
	clear_current_level()
	$UI/InGame.hide()
	$UI/Main.show()
	var peer = multiplayer.multiplayer_peer;
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	peer.close()
	type = GameType.None
