extends Node

const PORT = 4433

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
	start_game()


func _on_connect_pressed():
	# Start as client.
	var txt : String = $UI/MenuPlay/MenuConnect/Options/Remote.text
	if txt == "":
		OS.alert("Need a remote to connect to.")
		return
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(txt, PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer client.")
		return
	multiplayer.multiplayer_peer = peer
	start_game()


func start_game():
	# Hide the UI and unpause to start the game.
	$UI/MenuPlay.hide()
	if multiplayer.is_server():
		change_level(load("res://Scenes/Level1.tscn")) #call_deferred
	
# Call this function deferred and only on the main authority (server).
func change_level(scene: PackedScene):
	# Remove old level if any.
	var level = $Level
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	# Add new level.
	level.add_child(scene.instantiate())

# The server can restart the level by pressing Home.
func _input(event):
	"""
	if event.is_action("ui_cancel") and Input.is_action_just_pressed("ui_cancel"):
		var mig = $UI/MenuInGame
		if not mig.visible:
			mig.show()
		else:
			mig.hide()
	"""
	
	if not multiplayer.is_server():
		return
	if event.is_action("ui_home") and Input.is_action_just_pressed("ui_home"):
		change_level(load("res://Scenes/Level1.tscn")) #call_deferred


func _on_button_play_pressed() -> void:
	$UI/MenuMain.hide()
	$UI/MenuPlay.show()


func _on_button_exit_pressed() -> void:
	get_tree().quit()


func _on_button_back_pressed() -> void:
	$UI/MenuPlay.hide()
	$UI/MenuMain.show()
