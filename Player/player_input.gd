# player_input.gd
extends MultiplayerSynchronizer

# Synchronized property.
@export var direction := Vector2()
@export var cast_spell := false

func _ready():
	# Only process for the local player.
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())

func _process(_delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	cast_spell = Input.is_action_just_pressed("cast_spell")
