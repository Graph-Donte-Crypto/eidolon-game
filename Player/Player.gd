extends CharacterBody2D

class_name Player

const SPEED = 100.0

# Set by the authority, synchronized on spawn.
@export var player := 1 :
	set(id):
		player = id
		# Give authority over the player input to the appropriate peer.
		$PlayerInput.set_multiplayer_authority(id)

# Player synchronized input.
@onready var input = $PlayerInput
@onready var animation = $AnimatedSprite2D

var right = true
var last_direction = Vector2.RIGHT;

var SpellScene = preload("res://spell_instance/spell_instance.tscn")
func _process(_delta):
	if input.cast_spell:
		var dir = self.velocity.normalized()
		if dir == Vector2.ZERO:
			dir = last_direction
		spawn_projectile_on_all_peers.rpc_id(1, self.global_position, dir)

@rpc("call_local", "any_peer")
func spawn_projectile_on_all_peers(position: Vector2, direction: Vector2):
	var spell = SpellScene.instantiate()
	spell.global_position = position
	spell.direction = direction
	get_node(^"../../SpellInstances").add_child(spell, true)

func is_current():
	return player == multiplayer.get_unique_id()

func _ready():
	# Set the camera as current if we are this player.
	if player == multiplayer.get_unique_id():
		$Camera2D.make_current()
	# Only process on server.
	# EDIT: Let the client simulate player movement too to compesate network input latency.
	# set_physics_process(multiplayer.is_server())

func _physics_process(_delta):

	# Handle movement.
	var direction = input.direction.normalized()
	if direction:
		self.velocity = direction * SPEED
	else:
		self.velocity = self.velocity.move_toward(Vector2.ZERO, SPEED)



	if (self.velocity == Vector2.ZERO):
		if right:
			animation.play("idle_right")
		else:
			animation.play("idle_left")
	else:
		last_direction = self.velocity
		if velocity.x > 0:
			right = true
		elif velocity.x < 0:
			right = false

		if right:
			animation.play("walk_right")
		else:
			animation.play("walk_left")

	move_and_slide()
