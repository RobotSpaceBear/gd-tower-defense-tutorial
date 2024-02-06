extends CanvasLayer

func set_tower_preview(tower_type, mouse_position):
	var drag_tower = load("res://Scenes/Turrets/"+tower_type+".tscn").instance()
	drag_tower.set_name("DragTower")
	
	# can come up with this from the color picker, right side panel
	drag_tower.modulate = Color("ad54ff3c") 
	
	# preparing the range transparent sprite
	var range_texture = Sprite.new()
	range_texture.set_name("RangeSprite")
	range_texture.texture = load("res://Assets/UI/range_overlay.png")
	range_texture.position = Vector2(32, 32);
	var range_scale = GameData.tower_data[tower_type]["range"] / 600.0 # sprite texture is 600x600 px
	range_texture.scale = Vector2(range_scale, range_scale)
	range_texture.modulate = Color("ad54ff3c") 	
	
	# preparing the tower control
	var control = Control.new()
	control.add_child(drag_tower, true)
	control.rect_position = mouse_position
	control.set_name("TowerPreview")
	control.add_child(range_texture, true)
	
	# pushing the control + sprite to the UI
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
		get_node("TowerPreview/RangeSprite").modulate = Color(color)

##
## Game Control
##
func _on_PausePlay_pressed():
	if get_parent().build_mode:
		get_parent().cancel_build_mode()

	if get_tree().is_paused() :
		get_tree().paused = false
	elif get_parent().current_wave == 0:
		get_parent().current_wave += 1
		get_parent().start_next_wave()
	else :
		get_tree().paused = true


func _on_SpeedUp_pressed():
	if get_parent().build_mode:
		get_parent().cancel_build_mode()

	if Engine.get_time_scale() == 2.0:
		Engine.set_time_scale(1.0)
	else:
		Engine.set_time_scale(2.0)
