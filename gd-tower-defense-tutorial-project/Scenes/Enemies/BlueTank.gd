extends PathFollow2D

var speed = 150

func _ready():
	loop = false # prevents looping on the road path

func _physics_process(delta):
	move(delta)
	
func move(delta):
	set_offset(get_offset() + speed * delta)
