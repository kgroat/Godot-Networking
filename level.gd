extends Node2D

const SPAWN_RANDOM := 500.0
const Player = preload("res://player2d.gd")
const GameResource = preload("res://game_resource.gd")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# We only need to spawn players on the server.
	if !multiplayer.is_server():
		return
		
	for i in range(4):
		var pos := Vector2.from_angle(randf() * 2 * PI)
		var resource = preload("res://game_resource.tscn").instantiate()
		resource.position = Vector2(pos.x * SPAWN_RANDOM * randf(), pos.y * SPAWN_RANDOM * randf())
		$Resources.add_child(resource, true)

	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)

	# Spawn already connected players
	for id in multiplayer.get_peers():
		add_player(id)

	# Spawn the local player unless this is a dedicated server export.
	if not OS.has_feature("dedicated_server"):
		add_player(1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# We only need to spawn players on the server.
	if multiplayer.is_server():
		_process_grabs()


func _exit_tree():
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(del_player)


func add_player(id: int):
	var character = preload("res://player2d.tscn").instantiate()
	# Set player id.
	character.player = id
	# Randomize character position.
	var pos := Vector2.from_angle(randf() * 2 * PI)
	character.position = Vector2(pos.x * SPAWN_RANDOM * randf(), pos.y * SPAWN_RANDOM * randf())
	character.name = str(id)
	$Players.add_child(character, true)


func del_player(id: int):
	if not $Players.has_node(str(id)):
		return
	$Players.get_node(str(id)).queue_free()

func _find_closest_resource(pos: Vector2) -> GameResource:
	#pos = $Players.position + pos - $Resources.position
	var closest: GameResource = null
	var delta: float = INF
	for res in $Resources.get_children() as Array[GameResource]:
		if !closest:
			closest = res
			delta = (pos - res.position).length()
		elif (res.position - pos).length() < delta:
			closest = res
			delta = (pos - res.position).length()

	return closest

func _process_grabs():
	for player in $Players.get_children() as Array[Player]:
		if !player.grabbed && player.input.grabbing:
			if player.resource != GameResource.Types.NONE:
				var res = preload("res://game_resource.tscn").instantiate()
				res.position = player.position
				res.type = player.resource
				$Resources.add_child(res, true)
				player.resource = GameResource.Types.NONE
			else:
				var res = _find_closest_resource(player.position)
				if (res.position - player.position).length() < 50:
					$Resources.remove_child(res)
					player.resource = res.type
			player.grabbed = true
		elif player.grabbed && !player.input.grabbing:
			player.grabbed = false
