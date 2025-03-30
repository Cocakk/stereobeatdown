extends Node2D
@onready var tile_map_layer = $TileMap
var  floor_tile := Vector2i(26,36)
var wall_tile_bottom := Vector2i(27,36)
var wall_tile_top := Vector2i(27,38)
# Constants defining the grid size, cell size, and room parameters
const WIDTH = 80
const HEIGHT = 60
const CELL_SIZE = 16
const MIN_ROOM_SIZE = 5
const MAX_ROOM_SIZE = 10
const MAX_ROOMS = 6

# Arrays to hold the grid data and the list of rooms
var grid = []
var rooms = []

# _ready is called when the node is added to the scene
func _ready():
	# Initialize the random number generator
	randomize()
	# Create the grid filled with walls
	initialize_grid()
	# Generate the dungeon by placing rooms and connecting them
	generate_dungeon()
	# Draw the dungeon on the screen
	draw_dungeon()

# Initializes the grid with all cells set to walls (represented by 1)
func initialize_grid():
	for x in range(WIDTH):
		grid.append([])  # Add a new row to the grid
		for y in range(HEIGHT):
			grid[x].append(1)  # Fill each cell in the row with 1 (wall)

# Main function to generate the dungeon by placing rooms and connecting them
func generate_dungeon():
	for i in range(MAX_ROOMS):
		# Generate a room with random size and position
		var room = generate_room()
		# Attempt to place the room in the grid
		if place_room(room):
			# If this isn't the first room, connect it to the previous room
			if rooms.size() > 0:
				connect_rooms(rooms[-1], room)  # Connect the new room to the last placed room
			# Add the room to the list of rooms in the dungeon
			rooms.append(room)

# Generates a room with random width, height, and position within the grid
func generate_room():
	# Determine room width and height randomly within the specified range
	var width = randi() % (MAX_ROOM_SIZE - MIN_ROOM_SIZE + 1) + MIN_ROOM_SIZE
	var height = randi() % (MAX_ROOM_SIZE - MIN_ROOM_SIZE + 1) + MIN_ROOM_SIZE
	# Position the room randomly within the grid, ensuring it fits within the boundaries
	var x = randi() % (WIDTH - width - 1) + 1
	var y = randi() % (HEIGHT - height - 1) + 1
	# Return the room as a Rect2 object representing its position and size
	return Rect2(x, y, width, height)

# Attempts to place the room on the grid, ensuring no overlap with existing rooms
func place_room(room):
	# Check if the room overlaps with any existing floors (cells set to 0)
	for x in range(room.position.x, room.end.x):
		for y in range(room.position.y, room.end.y):
			if grid[x][y] == 0:  # If the cell is already a floor
				return false  # Room cannot be placed, return false
	
	# If no overlap is found, mark the room area as floors (set cells to 0)
	for x in range(room.position.x, room.end.x):
		for y in range(room.position.y, room.end.y):
			grid[x][y] = 0  # 0 represents a floor
	return true  # Room successfully placed, return true

# Connects two rooms with a corridor, allowing for a customizable corridor width
func connect_rooms(room1, room2, corridor_width=1):
	# Determine the starting point for the corridor (center of room1)
	var start = Vector2(
		int(room1.position.x + room1.size.x / 2),
		int(room1.position.y + room1.size.y / 2)
	)
	# Determine the ending point for the corridor (center of room2)
	var end = Vector2(
		int(room2.position.x + room2.size.x / 2),
		int(room2.position.y + room2.size.y / 2))
	
	var current = start
	
	# First, move horizontally towards the end point
	while current.x != end.x:
		# Move one step left or right
		current.x += 1 if end.x > current.x else -1
		# Create a corridor with the specified width
		for i in range(-int(corridor_width / 2), int(corridor_width / 2) + 1):
			for j in range(-int(corridor_width / 2), int(corridor_width / 2) + 1):
				# Ensure we don't go out of grid bounds
				if current.y + j >= 0 and current.y + j < HEIGHT and current.x + i >= 0 and current.x + i < WIDTH:
					grid[current.x + i][current.y + j] = 0  # Set cells to floor

	# Then, move vertically towards the end point
	while current.y != end.y:
		# Move one step up or down
		current.y += 1 if end.y > current.y else -1
		# Create a corridor with the specified width
		for i in range(-int(corridor_width / 2), int(corridor_width / 2) + 1):
			for j in range(-int(corridor_width / 2), int(corridor_width / 2) + 1):
				# Ensure we don't go out of grid bounds
				if current.x + i >= 0 and current.x + i < WIDTH and current.y + j >= 0 and current.y + j < HEIGHT:
					grid[current.x + i][current.y + j] = 0  # Set cells to floor

# Draws the dungeon on the screen by creating visual representations of the grid
func draw_dungeon():
	for x in range(WIDTH):
		for y in range(HEIGHT):
			var tile_position = Vector2i(x, y)  # Posição da célula no grid
			if grid[x][y] == 0:
				tile_map_layer.set_cell(0, tile_position, 0, floor_tile)  # Use set_cell com os parâmetros corretos
			elif grid[x][y] == 1:
				if y < HEIGHT - 1 and grid[x][y + 1] == 0:
					tile_map_layer.set_cell(0, tile_position, 0, wall_tile_bottom)  # Use set_cell com os parâmetros corretos
				elif y > 0 and grid[x][y - 1] == 0:
					tile_map_layer.set_cell(0, tile_position, 0, wall_tile_top)  # Use set_cell com os parâmetros corretos
				else:
					tile_map_layer.set_cell(0, tile_position, -1)  # Remove o tile se necessário
			else:
				tile_map_layer.set_cell(0, tile_position, -1)  # Remove o tile se necessário
