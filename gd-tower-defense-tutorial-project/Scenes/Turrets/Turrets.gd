extends Node2D

var enemy_array = []
var built = false
var enemy
var type
var ready = true

func _ready():
	if built:
		var shape_radius = 0.5 * GameData.tower_data[type]["range"]
		self.get_node("Range/CollisionShape2D").get_shape().radius = shape_radius
	print_debug("ready...")
	
func _physics_process(delta):
	if enemy_array.size() != 0 and built:
		select_enemy()
		turn()
		if ready:
			fire()
	else:
		enemy = null
	
func turn():
	var enemy_position = enemy.position
	get_node("Turret").look_at(enemy_position)

func select_enemy():
	## listing how far along the path (offset) each enemy is and selecting the 
	## enemy with the highest offset/ hoghest threat to us
	var enemy_progress_array = []
	for i in enemy_array :
		enemy_progress_array.append(i.offset)
	
	var max_offset = enemy_progress_array.max()
	var enemy_index = enemy_progress_array.find(max_offset)
	enemy = enemy_array[enemy_index]

func fire():
	ready = false
	enemy.on_hit(GameData.tower_data[type]["damage"])
	yield(get_tree().create_timer(GameData.tower_data[type]["rof"]), "timeout")
	ready = true


func _on_Range_body_entered(body):
	enemy_array.append(body.get_parent())
	print(enemy_array)

func _on_Range_body_exited(body):
	enemy_array.erase(body.get_parent())
