extends CanvasLayer

func set_tower_preview(tower_type, mouse_position):
	var drag_tower = load("res://Scenes/Turrets/"+tower_type+".tscn").instance()
	drag_tower.set_name("DragTower")
	
	# can come up with this from the color picker, right side panel
	drag_tower.modulate = Color("ad54ff3c") 
	
	var control = Control.new()
	control.add_child(drag_tower, true)
	control.rect_position = mouse_position
	control.set_name("TowerPreview")
	add_child(control, true)
	
	# UI rendered back to front, top to bottom, so we're drawing 
	# the preview BEHIND the rest of the UI
	move_child(get_node("TowerPreview"), 0) 
	
func update_tower_preview(new_position, color):
	get_node("TowerPreview").rect_position = new_position
	
	#updating the modulate is costly, we'll modulate only if 
	# the color should change
	if get_node("TowerPreview/DragTower").modulate != Color(color):
		get_node("TowerPreview/DragTower").modulate = Color(color)
