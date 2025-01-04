extends MultiplayerSynchronizer

# Set via RPC to simulate is_action_just_pressed.
@export var grabbing := false

# Synchronized property.
@export var direction := Vector2()


func _ready() -> void:
	# Only process for the local player
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())


@rpc("call_local")
func grab():
	grabbing = true


@rpc("call_local")
func release():
	grabbing = false


func _process(_delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_vector("left", "right", "up", "down")
	if Input.is_action_just_pressed("grab or drop"):
		grab.rpc()
	if Input.is_action_just_released("grab or drop"):
		release.rpc()
