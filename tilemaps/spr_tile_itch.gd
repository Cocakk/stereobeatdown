extends TileMap


# Called when the node enters the scene tree for the first time.
func _use_tile_data_runtime_update(layer, coords):
	if coords in get_used_cells_by_id(3):
		return true
	return false
	
	
func _tile_data_runtime_update(layer, coords, tile_data):
	tile_data.set_navigation_polygon(2, null)
