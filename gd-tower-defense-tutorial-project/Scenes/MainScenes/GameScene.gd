extends Node2D

var map_node
var build_type
var build_location
var build_tile
var build_mode = false
var build_valid = false

var current_wave = 0
var enemies_in_wave = 0

func _ready():
	map_node = get_node("Map1") # hardcoded for now
	for i in get_tree().get_nodes_in_group("build_buttons"):
		i.connect("pressed", self, "inititate_build_mode", [i.get_name()])

func _process(delta):
	if build_mode:
		update_tower_preview()
	
##
## Wave functions
##	
		
func start_next_wave():
	var wave_data = retrieve_wave_date()
	
	# giving the player a pause between, waves
	yield(get_tree().create_timer(0.5), "timeout") 
	spawn_enemies(wave_data)
	
func retrieve_wave_date():
	var wave_data = [["BlueTank", 1.0], ["BlueTank", 0.8], ["BlueTank", 0.7], ["BlueTank", 0.7], ["BlueTank", 0.7], ["BlueTank", 0.7], ["BlueTank", 0.7], ["BlueTank", 0.7], ["BlueTank", 0.7], ["BlueTank", 0.7], ["BlueTank", 0.7], ["BlueTank", 0.7]]
	current_wave += 1
	enemies_in_wave = wave_data.size()
	return wave_data
	
func spawn_enemies(wave_data):
	for i in wave_data:
		# wave_data[0..1][0]  => "BlueTank"
		var new_enemy = load("res://Scenes/Enemies/" + i[0] + ".tscn").instance()
		map_node.get_node("Path").add_child(new_enemy, true)
		yield(get_tree().create_timer(i[1]), "timeout")
		
		
##
## Build functions
##

func inititate_build_mode(tower_type):
	if build_mode :
		# allows changing towers while in build mode
		cancel_build_mode()
		
	build_type = tower_type + "T1"
	build_mode = true
	get_node("UI").set_tower_preview(build_type, get_global_mouse_position())
	
func update_tower_preview():
	var mouse_position = get_global_mouse_position()
	var current_tile = map_node.get_node("TowerExclusion").world_to_map(mouse_position)
	var tile_position = map_node.get_node("TowerExclusion").map_to_world(current_tile)
	
	if map_node.get_node("TowerExclusion").get_cellv(current_tile) == -1:
		get_node("UI").update_tower_preview(tile_position, "ad54ff3c")
		build_valid = true
		build_location = tile_position
		build_tile = current_tile
	else:
		get_node("UI").update_tower_preview(tile_position, "adff4545")
		build_valid = false

func _unhandled_input(event):
	if event.is_action_released("ui_cancel") and build_mode == true:
		cancel_build_mode()
	if event.is_action_released("ui_accept") and build_mode == true:
		verify_and_build()
		cancel_build_mode()
		
func cancel_build_mode():
	build_mode = false
	build_valid = false
	# used to be queue_free() for best practice but this needs to be freed
	# immediately, this frame, to avoid some null instance with the build mode
	get_node("UI/TowerPreview").queue_free()
	
func verify_and_build():
	if build_valid:
		var new_tower = load("res://Scenes/Turrets/"+ build_type +".tscn").instance()
		new_tower.position = build_location
		new_tower.built = true
		new_tower.type = build_type
		new_tower.category = GameData.tower_data[build_type]["category"]
		
		# adds the created tower to the Turrets layer
		map_node.get_node("Turrets").add_child(new_tower, true)
		
		# and this pushes the same tower to theexclusion layer so we can not
		# build future towers on this cell
		map_node.get_node("TowerExclusion").set_cellv(build_tile, 5)
		
