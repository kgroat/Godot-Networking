extends CharacterBody2D

const GameResource = preload("res://game_resource.gd")

# Set by the authority, synchronized on spawn.
@export var player := 1:
	set(id):
		player = id
		# Give authority over the player input to the appropriate peer.
		$PlayerInput.set_multiplayer_authority(id)

@export var grabbed = false

@export var resource: GameResource.Types = GameResource.Types.NONE

# Player synchronized input.
@onready var input = $PlayerInput
@onready var camera = $Camera2D

const SPEED = 300.0

func _ready() -> void:
	print(multiplayer)
	# Set the camera as current if we are this player.
	if player == multiplayer.get_unique_id():
		camera.make_current()

func _physics_process(_delta: float) -> void:
	# Handle movement.
	var direction = input.direction.normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.y = direction.y * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()
