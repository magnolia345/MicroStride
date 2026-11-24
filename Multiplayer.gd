extends Node3D

const PORT = 9999
@export var player_scene: PackedScene
@onready var players_container: Node3D = $Players

var peer = ENetMultiplayerPeer.new()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			host_game()
		elif event.keycode == KEY_2:
			join_game("127.0.0.1")
func host_game() -> void:
	var error = peer.create_server(PORT)
	if error != OK:
		print("Failed to host: ", error)
		return
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.peer_disconnected.connect(_remove_player)
	_add_player(multiplayer.get_unique_id()) # Spawns host (ID = 1)

func join_game(ip_address: String = "127.0.0.1") -> void:
	var error = peer.create_client(ip_address, PORT)
	if error != OK:
		print("Failed to join: ", error)
		return
	multiplayer.multiplayer_peer = peer
	# Notice: NO _add_player() call here! The host spawns you via MultiplayerSpawner.


func _add_player(id: int) -> void:
	var player = player_scene.instantiate()
	player.name = str(id)
	players_container.add_child(player)

func _remove_player(id: int) -> void:
	if players_container.has_node(str(id)):
		players_container.get_node(str(id)).queue_free()
