extends PathFollow2D

var speed = 150
var hp = 50

onready var health_bar = get_node("HealthBar")
onready var impact_area = get_node("Impact")
var projectile_impact = preload("res://Scenes/SupportScenes/ProjectileImpact.tscn")

func _ready():
	health_bar.max_value = hp
	health_bar.value = hp
	# puts this control on top of node tree so it's not affected 
	# by translation, rotation along the path
	health_bar.set_as_toplevel(true) 

	
	
func _physics_process(delta):
	move(delta)
	
func move(delta):
	set_offset(get_offset() + speed * delta)
	health_bar.set_position( position - Vector2(30, 40))

func on_hit(damage):
	impact()
	hp -= damage
	health_bar.value = hp
	if hp <= 0:
		on_destroy()
		
func impact():
	randomize()
	var x_position = randi() % 31
	randomize()
	var y_position = randi() % 31
	var impact_position = Vector2(x_position, y_position)
	var impact_instance = projectile_impact.instance()
	impact_instance.position = impact_position
	impact_area.add_child(impact_instance)

func on_destroy():
	# By removing the kinematicBody2D node first, it is removed from turrets'
	# range area so turrets don't fire on a dead tank anymore. We are delaying
	# the removal of the whole tank object to allow the impact animations to 
	# keep playing instead of the tank immediately disappearing as soon as the 
	# killing shot hits. The following yield allows for the animation to keep
	# playing, then the whole object is disposed
	get_node("KinematicBody2D").queue_free()
	yield(get_tree().create_timer(0.2), "timeout")
	self.queue_free()
